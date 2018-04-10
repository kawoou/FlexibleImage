//
//  ImageNoneDevice.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 10..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(OSX)
    import UIKit
#else
    import AppKit
#endif

internal class ImageNoneDevice: ImageDevice {

    // MARK: - Property
    
    internal var context: CGContext?
    internal var drawRect: CGRect?
    internal var memorySize: Int?
    internal var memoryPool: UnsafeMutablePointer<UInt8>?
    
    
    // MARK: - ImageDevice
    
    internal override func beginGenerate(_ isAlphaProcess: Bool) {
        /// Space Size
        let scale = self.imageScale
        
        guard let imageRef = self.cgImage else { return }
        defer { self.image = nil }
        
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
        
        /// Alloc Memory
        self.memorySize = width * height * 4
        self.memoryPool = UnsafeMutablePointer<UInt8>.allocate(capacity: self.memorySize!)
        memset(self.memoryPool!, 0, self.memorySize!)
        
        /// Create Context
        self.context = CGContext(
            data: self.memoryPool,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: (CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue)
        )
        
        /// Push Context
        guard let context = self.context else {
            self.drawRect = nil
            #if swift(>=4.1)
            self.memoryPool!.deallocate()
            #else
            self.memoryPool!.deallocate(capacity: self.memorySize!)
            #endif
            
            self.memorySize = nil
            self.memoryPool = nil
            return
        }
        
        /// Corner Radius
        if self.corner.isZero() == false {
            let cornerPath = self.corner.clipPath(spaceRect)
            context.addPath(cornerPath.cgPath)
            context.clip()
        }
        
        /// Draw Background
        if let background = self.background {
            context.saveGState()
            
            context.setBlendMode(.normal)
            context.setFillColor(background.cgColor)
            context.fill(spaceRect)
            
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
        
        /// Push clip
        context.saveGState()
        if !isAlphaProcess {
            context.clip(to: spaceRect, mask: context.makeImage()!)
        }
    }
    internal override func endGenerate() -> CGImage? {
        guard let context = self.context else { return nil }
        defer {
            self.drawRect = nil
            #if swift(>=4.1)
            self.memoryPool!.deallocate()
            #else
            self.memoryPool!.deallocate(capacity: self.memorySize!)
            #endif
            
            self.memorySize = nil
            self.memoryPool = nil
        }
        
        let scale = self.imageScale
        
        /// Pop clip
        context.restoreGState()
        
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
        let width = Int(self.drawRect!.width)
        let height = Int(self.drawRect!.height)
        self.postProcessList.forEach { closure in
            closure(context, width, height, memoryPool!)
        }
        
        /// Convert Image
        return context.makeImage()
    }
    
    // MARK: - Lifecycle
    
    internal override init() {
        super.init()
        
        self.type = .None
    }
    
}
