//
//  LinearLightFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class LinearLightFilter: ImageFilter {
    
    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "LinearLightFilter"
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
        
        func linearLight(_ a: UInt16, _ b: UInt16) -> UInt8 {
            if b < 128 {
                if a + 2 * b < 255 {
                    return 0
                } else {
                    return UInt8(a + 2 * b - 255)
                }
            } else {
                return UInt8(min(255, 2 * (Int32(b) - 128) + Int32(a)))
            }
        }
        
        var index = 0
        for _ in 0..<height {
            for _ in 0..<width {
                let r = UInt16(memoryPool[index + 0])
                let g = UInt16(memoryPool[index + 1])
                let b = UInt16(memoryPool[index + 2])
                let a = UInt16(memoryPool[index + 3])
                
                memoryPool[index + 0] = linearLight(r, UInt16(color.r * 255))
                memoryPool[index + 1] = linearLight(g, UInt16(color.g * 255))
                memoryPool[index + 2] = linearLight(b, UInt16(color.b * 255))
                memoryPool[index + 3] = linearLight(a, UInt16(color.a * 255))
                
                index += 4
            }
        }
        
        return super.processNone(device)
    }
    
}
