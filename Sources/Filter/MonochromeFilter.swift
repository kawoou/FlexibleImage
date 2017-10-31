//
//  MonochromeFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class MonochromeFilter: ImageFilter {
    
    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "MonochromeFilter"
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
        
        func monochrome(_ a: Float, _ l: Float, _ d: Float) -> UInt8 {
            var ret: UInt8
            if l < 128 {
                ret = UInt8(2.0 * l * d)
            } else {
                let l = 255 - l
                let d = 1.0 - d
                
                let first = Int32(255.0 - 2.0 * l * d)
                ret = UInt8(max(min(first, 255), 0))
            }
            
            return UInt8(a * (1.0 - self.threshold) + Float(ret) * self.threshold)
        }
        
        var index = 0
        for _ in 0..<height {
            for _ in 0..<width {
                let r = Float(memoryPool[index + 0])
                let g = Float(memoryPool[index + 1])
                let b = Float(memoryPool[index + 2])
                
                let luminance = min(255.0, r * 0.2125 + g * 0.7154 + b * 0.0721)
                
                memoryPool[index + 0] = monochrome(r, luminance, 0.6)
                memoryPool[index + 1] = monochrome(g, luminance, 0.45)
                memoryPool[index + 2] = monochrome(b, luminance, 0.3)
                
                index += 4
            }
        }
        
        return super.processNone(device)
    }
    
}
