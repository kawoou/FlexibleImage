//
//  ImageMetalDevice.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 9..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(OSX)
    import UIKit
#else
    import AppKit
#endif

#if !os(watchOS)
    import Metal
#endif

#if !os(watchOS)
    @available(OSX 10.11, iOS 8, tvOS 9, *)
    internal class ImageMetalDevice: ImageDevice {
        
        // MARK: - Property
        
        internal let device: MTLDevice
        internal let commandQueue: MTLCommandQueue
        
        internal var drawRect: CGRect?
        internal var texture: MTLTexture?
        internal var outputTexture: MTLTexture?
        
        
        // MARK: - Internal
        
        internal func makeTexture() {
            /// Calc size
            let width = Int(self.drawRect!.width)
            let height = Int(self.drawRect!.height)
            
            guard self.texture == nil else { return }
            guard let imageRef = self.cgImage else { return }
            defer { self.image = nil }
            
            /// Space Size
            let scale = self.imageScale
            
            /// Alloc Memory
            let memorySize = width * height * 4
            let memoryPool = UnsafeMutablePointer<UInt8>.allocate(capacity: memorySize)
            defer {
                #if swift(>=4.1)
                memoryPool.deallocate()
                #else
                memoryPool.deallocate(capacity: memorySize)
                #endif
            }
            memset(memoryPool, 0, memorySize)
            
            /// Create Context
            let bitmapContext = CGContext(
                data: memoryPool,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
            )
            
            guard let context = bitmapContext else { return }
            
            /// Draw Background
            if let background = self.background {
                context.saveGState()
                
                context.setBlendMode(.normal)
                context.setFillColor(background.cgColor)
                context.fill(self.drawRect!)
                
                context.restoreGState()
            }
            
            /// Draw
            let size = self.scale ?? self.spaceSize
            let tempX = self.offset.x + self.margin.left + self.padding.left
            let tempY = self.offset.y + self.margin.top + self.padding.top
            
            context.saveGState()
            context.setBlendMode(.normal)
            context.setAlpha(self.opacity)
            
            if let rotateRadius = self.rotate {
                context.translateBy(
                    x: self.spaceSize.width * 0.5,
                    y: self.spaceSize.height * 0.5
                )
                context.rotate(by: rotateRadius)
                
                let calcX = -size.width * 0.5 + tempX
                let calcY = -size.height * 0.5 + tempY
                let rect = CGRect(
                    x: calcX * scale,
                    y: calcY * scale,
                    width: size.width * scale,
                    height: size.height * scale
                )
                self.draw(imageRef, in: rect, on: context)
            } else {
                let rect = CGRect(
                    x: tempX * scale,
                    y: tempY * scale,
                    width: size.width * scale,
                    height: size.height * scale
                )
                self.draw(imageRef, in: rect, on: context)
            }
            context.restoreGState()
            
            /// Make texture
            let descriptor = MTLTextureDescriptor.texture2DDescriptor(
                pixelFormat: .rgba8Unorm,
                width: width,
                height: height,
                mipmapped: false
            )

            #if swift(>=4.0)
                guard let texture = self.device.makeTexture(descriptor: descriptor) else { return }
            #else
                let texture = self.device.makeTexture(descriptor: descriptor)
            #endif
            texture.replace(
                region: MTLRegionMake2D(0, 0, width, height),
                mipmapLevel: 0,
                withBytes: memoryPool,
                bytesPerRow: width * 4
            )
            
            self.texture = texture
            self.outputTexture = self.device.makeTexture(descriptor: descriptor)
        }
        internal func swapBuffer() {
            let oldTexture = self.texture
            self.texture = self.outputTexture
            self.outputTexture = oldTexture
        }
        
        internal override func beginGenerate(_ isAlphaProcess: Bool) {
            /// Space Size
            let scale = self.imageScale
            
            /// Calc size
            let tempW = self.spaceSize.width + self.margin.horizontal + self.padding.horizontal
            let tempH = self.spaceSize.height + self.margin.vertical + self.padding.vertical
            let width = Int(tempW * scale)
            let height = Int(tempH * scale)
            let spaceRect = CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height
            )
            self.drawRect = spaceRect
            
            self.makeTexture()
        }
        internal override func endGenerate() -> CGImage? {
            guard let texture = self.texture else { return nil }
            defer {
                self.texture = nil
                self.outputTexture = nil
            }
            
            let scale = self.imageScale
            
            let width = Int(self.drawRect!.width)
            let height = Int(self.drawRect!.height)
            
            let memorySize = width * height * 4
            let memoryPool = UnsafeMutablePointer<UInt8>.allocate(capacity: memorySize)
            defer {
                #if swift(>=4.1)
                memoryPool.deallocate()
                #else
                memoryPool.deallocate(capacity: memorySize)
                #endif
            }
            
            texture.getBytes(
                memoryPool,
                bytesPerRow: width * 4,
                from: MTLRegionMake2D(0, 0, width, height),
                mipmapLevel: 0
            )
            
            let bitmapContext = CGContext(
                data: memoryPool,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
            )
            
            guard let context = bitmapContext else { return nil }
            
            /// Draw border
            if let border = self.border {
                let borderPath: FIBezierPath
                let borderSize = self.scale ?? self.spaceSize
                let borderRect = CGRect(
                    x: (self.offset.x + self.margin.left) * scale,
                    y: (self.offset.y + self.margin.top) * scale,
                    width: (borderSize.width + self.padding.left + self.padding.right) * scale,
                    height: (borderSize.height + self.padding.top + self.padding.bottom) * scale
                )
                
                if border.radius > 0 {
                    #if !os(OSX)
                        borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: border.radius * 2)
                    #else
                        borderPath = NSBezierPath(roundedRect: borderRect, xRadius: border.radius * 2, yRadius: border.radius * 2)
                    #endif
                } else {
                    borderPath = FIBezierPath(rect: borderRect)
                }
                
                context.saveGState()
                
                context.setStrokeColor(border.color.cgColor)
                context.addPath(borderPath.cgPath)
                context.setLineWidth(border.lineWidth)
                context.replacePathWithStrokedPath()
                context.drawPath(using: .stroke)
                
                context.restoreGState()
            }
            
            /// Post-processing
            self.postProcessList.forEach { closure in
                closure(context, texture.width, texture.height, memoryPool)
            }
            
            guard let cgImage = context.makeImage() else { return nil }
            
            /// Corner Radius
            if self.corner.isZero() == false {
                let cornerDrawContext = CGContext(
                    data: nil,
                    width: width,
                    height: height,
                    bitsPerComponent: 8,
                    bytesPerRow: width * 4,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
                )
                
                guard let cornerContext = cornerDrawContext else { return nil }
                
                let cornerPath = self.corner.clipPath(self.drawRect!)
                cornerContext.addPath(cornerPath.cgPath)
                cornerContext.clip()
                
                cornerContext.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
                
                /// Convert Image
                return cornerContext.makeImage()
            } else {
                /// Convert Image
                return cgImage
            }
        }
        
        
        // MARK: - Lifecycle
        
        internal override init() {
            #if os(OSX)
                let devices = MTLCopyAllDevices()
                for device in devices {
                    // [0] -> "AMD Radeon Pro 455", [1] -> "Intel(R) HD Graphics 530"
                    #if swift(>=4.0)
                        print(device.name)
                    #else
                        print(device.name!)
                    #endif
                }
                
                self.device = devices[0]
            #else
                // Make device
                self.device = MTLCreateSystemDefaultDevice()!
            #endif
            
            // Make command queue
            #if swift(>=4.0)
                self.commandQueue = self.device.makeCommandQueue()!
            #else
                self.commandQueue = self.device.makeCommandQueue()
            #endif
            
            super.init()
            
            self.type = .Metal
            
        }
        
    }
#endif
