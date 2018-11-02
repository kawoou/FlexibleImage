//
//  ImageDevice.swift
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

internal enum ImageDeviceType {
    case None
    case Metal
}

internal class ImageDevice {
    
    // MARK: - Property
    
    internal var type: ImageDeviceType
    internal var image: FIImage? {
        didSet {
            if let image = self.image {
                self.cgImage = image.cgImage
                self.imageScale = image.scale
                #if !os(OSX)
                    self.imageOrientation = image.imageOrientation
                #endif
                self.spaceSize = CGSize(
                    width: image.size.width,
                    height: image.size.height
                )
            } else {
                self.cgImage = nil
                self.imageScale = 1.0
                #if !os(OSX)
                    self.imageOrientation = .up
                #endif
                self.spaceSize = .zero
            }
        }
    }
    internal var cgImage: CGImage?
    #if !os(OSX)
    internal var imageOrientation: UIImage.Orientation = .up
    #endif
    internal var imageScale: CGFloat = 1.0
    
    internal var background: FIColor?
    internal var offset: CGPoint = .zero
    internal var scale: CGSize?
    internal var rotate: CGFloat?
    internal var opacity: CGFloat = 1.0
    internal var corner: CornerType = CornerType(0)
    
    internal var border: (color: FIColor, lineWidth: CGFloat, radius: CGFloat)?
    
    internal var spaceSize: CGSize = .zero
    internal var margin: EdgeInsets = .zero
    internal var padding: EdgeInsets = .zero
    
    internal var postProcessList: [ContextType] = []
    
    
    // MARK: - Public
    
    internal func beginGenerate(_ isAlphaProcess: Bool) { return }
    internal func endGenerate() -> CGImage? { return nil }
    
    internal func draw(_ cgImage: CGImage, in rect: CGRect, on context: CGContext) {
        context.saveGState()
        
        #if !os(OSX)
            if let image = self.image {
                /// Golden-Path
                if self.imageOrientation == .up {
                    context.draw(cgImage, in: rect)
                    return
                }
                
                let width  = image.size.width * self.imageScale
                let height = image.size.height * self.imageScale
                
                var transform = CGAffineTransform.identity
                
                switch self.imageOrientation {
                case .down, .downMirrored:
                    transform = transform.translatedBy(x: width, y: height)
                    transform = transform.rotated(by: CGFloat.pi)
                    
                case .left, .leftMirrored:
                    transform = transform.translatedBy(x: width, y: 0)
                    transform = transform.rotated(by: 0.5 * CGFloat.pi)
                    
                case .right, .rightMirrored:
                    transform = transform.translatedBy(x: 0, y: height)
                    transform = transform.rotated(by: -0.5 * CGFloat.pi)
                    
                default:
                    break
                }
                
                switch self.imageOrientation {
                case .upMirrored, .downMirrored:
                    transform = transform.translatedBy(x: width, y: 0)
                    transform = transform.scaledBy(x: -1, y: 1)
                    
                case .leftMirrored, .rightMirrored:
                    transform = transform.translatedBy(x: height, y: 0)
                    transform = transform.scaledBy(x: -1, y: 1)
                    
                default:
                    break
                }
                
                context.concatenate(transform)
                
                switch self.imageOrientation {
                case .left, .leftMirrored, .right, .rightMirrored:
                    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: height, height: width))
                    
                default:
                    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
                }
                
            } else {
                
                context.draw(cgImage, in: rect)
                
            }
        #else
            context.draw(cgImage, in: rect)
        #endif
        
        context.restoreGState()
    }
    
    
    // MARK: - Lifecycle
    
    internal init() {
        self.type = .None
    }
    
}
