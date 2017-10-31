//
//  FIImage.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 10..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(OSX)
    import UIKit
    public typealias FIImage = UIImage
#else
    import AppKit
    public typealias FIImage = NSImage
    
    internal extension FIImage {
        internal var cgImage: CGImage? {
            get {
                return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
            }
        }
        internal var scale: CGFloat {
            return 1.0
        }
    }
#endif
