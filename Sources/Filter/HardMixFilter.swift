//
//  HardMixFilter.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(watchOS)
    import Metal
#endif

internal class HardMixFilter: ImageFilter {
    
    // MARK: - Property
    
    internal override var metalName: String {
        get {
            return "HardMixFilter"
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
        
        func vividLight(_ a: Float, _ b: Float) -> Float {
            if b < 0.5 {
                if b == 0.0 {
                    return 0
                } else {
                    let a = 1.0 - a
                    return max(1.0 - (a / b), 0.0)
                    
                }
            } else {
                if b == 1.0 {
                    return 0
                } else {
                    let b = 1.0 - b
                    return min(a / b, 1.0)
                }
            }
        }
        
        func hardMix(_ a: Float, _ b: Float) -> UInt8 {
            let vivid = vividLight(a, b)
            
            if vivid < 0.5 {
                return 0
            } else {
                return 255
            }
        }
        
        var index = 0
        for _ in 0..<height {
            for _ in 0..<width {
                let r = Float(memoryPool[index + 0]) / 255.0
                let g = Float(memoryPool[index + 1]) / 255.0
                let b = Float(memoryPool[index + 2]) / 255.0
                let a = Float(memoryPool[index + 3]) / 255.0
                
                memoryPool[index + 0] = hardMix(r, color.r)
                memoryPool[index + 1] = hardMix(g, color.g)
                memoryPool[index + 2] = hardMix(b, color.b)
                memoryPool[index + 3] = hardMix(a, color.a)
                
                index += 4
            }
        }
        
        return super.processNone(device)
    }
    
}
