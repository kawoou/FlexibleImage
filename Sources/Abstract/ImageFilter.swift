//
//  ImageFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 9..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class ImageFilter {
    
    // MARK: - Property
    
    internal var metalName: String {
        get {
            return ""
        }
    }
    
    
    // MARK: - Variable
    
    internal var metalPipeline: AnyObject? /// MTLComputePipelineState?
    
    
    // MARK: - Private
    
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        private func loadMetalPipeline(device: MTLDevice) -> MTLComputePipelineState? {
            guard let bundle = Bundle(identifier: "io.kawoou.FlexibleImage") ?? Bundle(identifier: "org.cocoapods.FlexibleImage") else { return nil }
            guard let filePath = bundle.path(forResource: "default", ofType: "metallib") else { return nil }
            guard self.metalName.lengthOfBytes(using: .ascii) > 0 else { return nil }
            
            
            do {
                let library = try device.makeLibrary(filepath: filePath)
                guard let function = library.makeFunction(name: self.metalName) else { return nil }
                
                return try device.makeComputePipelineState(function: function)
            } catch let error {
                print(error)
                return nil
            }
        }
    #endif
    
    
    // MARK: - Internal
    
    internal func process(device: ImageDevice) -> Bool {
        if device.type == .Metal {
            #if !os(watchOS)
                if #available(OSX 10.11, *) {
                    guard let device = device as? ImageMetalDevice else { return false }
                    
                    // Add command queue
                    #if swift(>=4.0)
                        guard let commandBuffer = device.commandQueue.makeCommandBuffer() else { return false }
                        guard let commandEncoder = commandBuffer.makeComputeCommandEncoder() else { return false }
                    #else
                        let commandBuffer = device.commandQueue.makeCommandBuffer()
                        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
                    #endif
                    
                    if let pipeline = self.metalPipeline as? MTLComputePipelineState {
                        // Set pipeline
                        commandEncoder.setComputePipelineState(pipeline)
                        
                        // Set texture
                        #if swift(>=4.0)
                            commandEncoder.setTexture(device.outputTexture!, index: 0)
                            commandEncoder.setTexture(device.texture!, index: 1)
                        #else
                            commandEncoder.setTexture(device.outputTexture!, at: 0)
                            commandEncoder.setTexture(device.texture!, at: 1)
                        #endif
                    }
                    
                    let retValue = self.processMetal(device, commandBuffer, commandEncoder)
                    device.swapBuffer()
                    
                    return retValue
                } else {
                    return false
                }
            #else
                return self.processNone(device as! ImageNoneDevice)
            #endif
        } else {
            return self.processNone(device as! ImageNoneDevice)
        }
    }
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        internal func processMetal(_ device: ImageMetalDevice, _ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLComputeCommandEncoder) -> Bool {
            // Draw
            guard let pipeline = self.metalPipeline as? MTLComputePipelineState else {
                commandEncoder.endEncoding()
                commandBuffer.commit()
                commandBuffer.waitUntilCompleted()
                return false
            }
            
            let w = pipeline.threadExecutionWidth
            let h = pipeline.maxTotalThreadsPerThreadgroup / w
            
            commandEncoder.dispatchThreadgroups(
                MTLSizeMake(Int(ceil(device.drawRect!.width / CGFloat(w))), Int(ceil(device.drawRect!.height / CGFloat(h))), 1),
                threadsPerThreadgroup: MTLSizeMake(w, h, 1)
            )
            commandEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            
            return true
        }
    #endif
    internal func processNone(_ device: ImageNoneDevice) -> Bool {
        return true
    }
    
    
    // MARK: - Lifecyle
    
    internal init(device: ImageDevice) {
        #if !os(watchOS)
            if #available(OSX 10.11, *) {
                if device.type == .Metal {
                    let metalDevice = device as! ImageMetalDevice
                    
                    self.metalPipeline = self.loadMetalPipeline(device: metalDevice.device)
                }
            }
        #endif
    }
    
}
