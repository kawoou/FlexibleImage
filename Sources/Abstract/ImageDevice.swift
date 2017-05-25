//
//  ImageDevice.swift
//  Test Project
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
                self.spaceSize = CGSize(
                    width: image.size.width,
                    height: image.size.height
                )
            } else {
                self.cgImage = nil
                self.imageScale = 1.0
                self.spaceSize = .zero
            }
        }
    }
    internal var cgImage: CGImage?
    internal var imageScale: CGFloat = 1.0
    
    internal var background: FIColor?
    internal var offset: CGPoint = .zero
    internal var scale: CGSize?
    internal var rotate: CGFloat?
    internal var opacity: CGFloat = 1.0
    internal var corner: CornerType = CornerType(0)
    
    internal var border: (color: FIColor, lineWidth: CGFloat, radius: CGFloat)?
    
    internal var spaceSize: CGSize
    internal var margin: EdgeInsets = .zero
    internal var padding: EdgeInsets = .zero
    
    internal var postProcessList: [ContextType] = []
    
    
    // MARK: - Public

    internal func beginGenerate(_ isAlphaProcess: Bool) { return }
    internal func endGenerate() -> CGImage? { return nil }
    
    
    // MARK: - Lifecycle
    
    internal init() {
        self.type = .None
    }
    
}
