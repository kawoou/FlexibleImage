//
//  BlurFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
    #if !os(OSX) && !arch(i386) && !arch(x86_64)
        import MetalPerformanceShaders
    #endif
#endif

#if !os(watchOS)
    import Accelerate

    internal class BlurFilter: ImageFilter {
        
        // MARK: - Property
        
        internal override var metalName: String {
            get {
                #if !os(OSX) && !arch(i386) && !arch(x86_64)
                    if #available(iOS 9, *) {
                        return ""
                    }
                #endif
                
                return "BlurFilter"
            }
        }
        
        internal var radius: Float = 20.0
        
        
        // MARK: - Private
        
        private var weightTexture: AnyObject? // MTLTexture?
        
        #if !os(watchOS)
            @available(OSX 10.11, iOS 8, tvOS 9, *)
            private func makeWeightTexture(_ device: MTLDevice) {
                let sigma = self.radius / 2.0
                let size = Int(round(self.radius) * 2 + 1)
                
                var delta = Float(0)
                var expScale = Float(0)
                
                if self.radius > 0.0 {
                    delta = (self.radius * 2) / Float(size - 1)
                    expScale = -1 / (2 * sigma * sigma)
                }
                
                let rawData = UnsafeMutablePointer<Float>.allocate(capacity: size * size)
                defer {
                    #if swift(>=4.1)
                    rawData.deallocate()
                    #else
                    rawData.deallocate(capacity: size * size)
                    #endif
                }
                
                var weightSum = Float(0)
                var y = -self.radius
                
                for j in 0..<size {
                    var x = -self.radius
                    
                    for i in 0..<size {
                        let weight = expf((x * x + y * y) * expScale)
                        rawData[j * size + i] = weight
                        weightSum += weight
                        
                        x += delta
                    }
                    y += delta
                }
                
                let weightScale = 1 / weightSum
                for j in 0..<size {
                    for i in 0..<size {
                        rawData[j * size + i] *= weightScale
                    }
                }
                
                let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                    pixelFormat: .r32Float,
                    width: size,
                    height: size,
                    mipmapped: false
                )
                #if swift(>=4.0)
                    guard let texture = device.makeTexture(descriptor: descriptor) else { return }
                #else
                    let texture = device.makeTexture(descriptor: descriptor)
                #endif
                texture.replace(
                    region: MTLRegionMake2D(0, 0, size, size),
                    mipmapLevel: 0,
                    withBytes: rawData,
                    bytesPerRow: size * 4
                )
                
                self.weightTexture = texture
            }
        #endif
        
        
        // MARK: - Internal
        
        #if !os(watchOS)
            @available(OSX 10.11, iOS 8, tvOS 9, *)
            internal override func processMetal(_ device: ImageMetalDevice, _ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLComputeCommandEncoder) -> Bool {
                #if !os(OSX) && !arch(i386) && !arch(x86_64)
                    if #available(iOS 9, *) {
                        commandEncoder.endEncoding()
                        
                        let blur = MPSImageGaussianBlur(device: device.device, sigma: self.radius / 2)
                        
                        /// Draw
                        blur.encode(commandBuffer: commandBuffer, sourceTexture: device.texture!, destinationTexture: device.outputTexture!)
                        
                        commandBuffer.commit()
                        commandBuffer.waitUntilCompleted()
                        
                        return true
                    }
                #endif
                
                let factors: [Float] = [self.radius]
                
                if let texture = self.weightTexture as? MTLTexture {
                    #if swift(>=4.0)
                        commandEncoder.setTexture(texture, index: 2)
                    #else
                        commandEncoder.setTexture(texture, at: 2)
                    #endif
                } else {
                    self.makeWeightTexture(device.device)
                    #if swift(>=4.0)
                        commandEncoder.setTexture(self.weightTexture as? MTLTexture, index: 2)
                    #else
                        commandEncoder.setTexture(self.weightTexture as? MTLTexture, at: 2)
                    #endif
                }
                
                for i in 0..<factors.count {
                    var factor = factors[i]
                    let size = max(MemoryLayout<Float>.size, 16)
                    
                    let options: MTLResourceOptions
                    if #available(iOS 9.0, *) {
                        options = [.storageModeShared]
                    } else {
                        options = [.cpuCacheModeWriteCombined]
                    }
                    
                    let buffer = device.device.makeBuffer(
                        bytes: &factor,
                        length: size,
                        options: options
                    )
                    #if swift(>=4.0)
                        commandEncoder.setBuffer(buffer, offset: 0, index: i)
                    #else
                        commandEncoder.setBuffer(buffer, offset: 0, at: i)
                    #endif
                }
                
                return super.processMetal(device, commandBuffer, commandEncoder)
            }
        #endif
        
        override func processNone(_ device: ImageNoneDevice) -> Bool {
            let memoryPool = device.memoryPool!
            let width = Int(device.drawRect!.width)
            let height = Int(device.drawRect!.height)
            
            /// Source Buffer
            var srcBuffer = vImage_Buffer(
                data: memoryPool,
                height: UInt(height),
                width: UInt(width),
                rowBytes: device.context!.bytesPerRow
            )
            
            /// Alloc Memory
            let destMemorySize = width * height * 4
            let destMemoryPool = UnsafeMutablePointer<UInt8>.allocate(capacity: destMemorySize)
            defer {
                #if swift(>=4.1)
                destMemoryPool.deallocate()
                #else
                destMemoryPool.deallocate(capacity: destMemorySize)
                #endif
            }
            memcpy(destMemoryPool, memoryPool, destMemorySize)
            
            /// Destination Buffer
            var destBuffer = vImage_Buffer(
                data: destMemoryPool,
                height: vImagePixelCount(height),
                width: vImagePixelCount(width),
                rowBytes: device.context!.bytesPerRow
            )
            
            /// Effect
            let d1 = self.radius * 1.5 * sqrt(2 * Float.pi) / 4
            let d2 = floor(d1 + 0.5)
            
            var radius = UInt32(d2)
            if radius % 2 != 1 {
                radius += 1
            }
            
            let flags = vImage_Flags(kvImageEdgeExtend)
            vImageBoxConvolve_ARGB8888(&destBuffer, &srcBuffer, nil, 0, 0, radius, radius, nil, flags)
            vImageBoxConvolve_ARGB8888(&srcBuffer, &destBuffer, nil, 0, 0, radius, radius, nil, flags)
            vImageBoxConvolve_ARGB8888(&destBuffer, &srcBuffer, nil, 0, 0, radius, radius, nil, flags)
            
            return super.processNone(device)
        }
        
    }
#endif
