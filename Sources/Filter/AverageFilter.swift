//
//  AverageFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 10..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class AverageFilter: ImageFilter {

    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "AverageFilter"
        }
    }
    
    internal var color: FIColorType = (1.0, 1.0, 1.0, 1.0)
    
    
    // MARK: - Internal
    
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        internal override func processMetal(_ device: ImageMetalDevice, _ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLComputeCommandEncoder) -> Bool {
            let factors: [Float] = [color.r, color.g, color.b, color.a]
            
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
                let a = Float(memoryPool[index + 3])
                
                memoryPool[index + 0] = UInt8((self.color.r * 255 + r) * 0.5)
                memoryPool[index + 1] = UInt8((self.color.g * 255 + g) * 0.5)
                memoryPool[index + 2] = UInt8((self.color.b * 255 + b) * 0.5)
                memoryPool[index + 3] = UInt8((self.color.a * 255 + a) * 0.5)
                
                index += 4
            }
        }
        
        return super.processNone(device)
    }
    
}
