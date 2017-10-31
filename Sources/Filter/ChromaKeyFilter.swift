//
//  ChromaKeyFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class ChromaKeyFilter: ImageFilter {
    
    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "ChromaKeyFilter"
        }
    }
    
    internal var threshold: Float = 0.4
    internal var smoothing: Float = 0.1
    internal var color: FIColorType = (0.0, 1.0, 0.0, 1.0)
    
    
    // MARK: - Internal
    
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        internal override func processMetal(_ device: ImageMetalDevice, _ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLComputeCommandEncoder) -> Bool {
            let factors: [Float] = [self.color.r, self.color.g, self.color.b, self.threshold, self.smoothing]
            
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
        
        let maskY = self.color.r * 0.2989 + self.color.g * 0.5866 + self.color.b * 0.1145
        let maskCr = 0.7131 * (self.color.r - maskY)
        let maskCb = 0.5647 * (self.color.b - maskY)
        
        func smoothstep(_ minValue: Float, _ maxValue: Float, _ t: Float) -> Float {
            let first = (t - minValue) / (maxValue - minValue)
            let output = min(max(first, 0.0), 1.0)
            
            return output * output * (3.0 - 2.0 * output)
        }
        
        var index = 0
        for _ in 0..<height {
            for _ in 0..<width {
                let r = Float(memoryPool[index + 0]) / 255.0
                let g = Float(memoryPool[index + 1]) / 255.0
                let b = Float(memoryPool[index + 2]) / 255.0
                
                let Y = r * 0.2989 + g * 0.5866 + b * 0.1145
                let Cr = 0.7131 * (r - Y)
                let Cb = 0.5647 * (b - Y)
                
                let length = sqrt(pow(Cr - maskCr, 2) + pow(Cb - maskCb, 2))
                let alpha = smoothstep(self.threshold, self.threshold + self.smoothing, length)
                
                memoryPool[index + 3] = UInt8(Float(memoryPool[index + 3]) * alpha)
                
                index += 4
            }
        }
        
        return super.processNone(device)
    }
    
}
