//
//  GreyscaleFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class GreyscaleFilter: ImageFilter {
    
    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "GreyscaleFilter"
        }
    }
    
    internal var threshold: Float = 1.0
    
    
    // MARK: - Internal
    
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        internal override func processMetal(_ device: ImageMetalDevice, _ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLComputeCommandEncoder) -> Bool {
            let factors: [Float] = [self.threshold]
            
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
        
        var index = 0
        for _ in 0..<height {
            for _ in 0..<width {
                let r = Float(memoryPool[index + 0])
                let g = Float(memoryPool[index + 1])
                let b = Float(memoryPool[index + 2])
                
                let delta = (r * 0.299 + g * 0.587 + b * 0.114) * self.threshold
                
                memoryPool[index + 0] = UInt8(r * (1.0 - self.threshold) + delta)
                memoryPool[index + 1] = UInt8(g * (1.0 - self.threshold) + delta)
                memoryPool[index + 2] = UInt8(b * (1.0 - self.threshold) + delta)
                
                index += 4
            }
        }
        
        return super.processNone(device)
    }
    
}
