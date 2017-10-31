//
//  VibranceFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class VibranceFilter: ImageFilter {
    
    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "VibranceFilter"
        }
    }
    
    internal var vibrance: Float = 0.0
    
    
    // MARK: - Internal
    
    #if !os(watchOS)
        @available(OSX 10.11, iOS 8, tvOS 9, *)
        internal override func processMetal(_ device: ImageMetalDevice, _ commandBuffer: MTLCommandBuffer, _ commandEncoder: MTLComputeCommandEncoder) -> Bool {
            let factors: [Float] = [vibrance]
            
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
        
        let vibranceOffset = -self.vibrance * 3.0
        
        func calc(_ a: Float, _ mx: Float, _ amt: Float) -> UInt8 {
            let first = a * (1.0 - amt)
            let second = mx * amt
            return UInt8(max(min(first + second, 255), 0))
        }
        
        var index = 0
        for _ in 0..<height {
            for _ in 0..<width {
                let r = Float(memoryPool[index + 0])
                let g = Float(memoryPool[index + 1])
                let b = Float(memoryPool[index + 2])
                
                let avg = (r + g + b) / 3.0
                let mx = max(r, max(g, b))
                let amt = (mx - avg) / 255.0 * vibranceOffset
                
                memoryPool[index + 0] = calc(r, mx, amt)
                memoryPool[index + 1] = calc(g, mx, amt)
                memoryPool[index + 2] = calc(b, mx, amt)
                
                index += 4
            }
        }
        
        return super.processNone(device)
    }
    
}
