//
//  FIColor.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 12..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(OSX)
    import UIKit
    public typealias FIColor = UIColor
#else
    import AppKit
    public typealias FIColor = NSColor
#endif

internal extension FIColor {
    internal var imageColor: FIColorType {
        get {
            #if os(OSX)
                let rgba = CIColor(color: self)!
                return FIColorType(Float(rgba.red), Float(rgba.green), Float(rgba.blue), Float(rgba.alpha))
            #else
                var r = CGFloat(0)
                var g = CGFloat(0)
                var b = CGFloat(0)
                var a = CGFloat(0)
                self.getRed(&r, green: &g, blue: &b, alpha: &a)
                
                return FIColorType(Float(r), Float(g), Float(b), Float(a))
            #endif
        }
    }
}
