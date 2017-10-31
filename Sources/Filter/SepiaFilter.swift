//
//  SepiaFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class SepiaFilter: ImageFilter {
    
    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "SepiaFilter"
        }
    }
    
    
    // MARK: - Internal
    
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        internal override func processMetal(_ device: ImageMetalDevice, _ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLComputeCommandEncoder) -> Bool {
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
                
                let ra = r * 0.393 + g * 0.769 + b * 0.189
                let ga = r * 0.349 + g * 0.686 + b * 0.168
                let ba = r * 0.272 + g * 0.534 + b * 0.131
                
                memoryPool[index + 0] = UInt8(min(ra, 255))
                memoryPool[index + 1] = UInt8(min(ga, 255))
                memoryPool[index + 2] = UInt8(min(ba, 255))
                
                index += 4
            }
        }
        
        return super.processNone(device)
    }
    
}
