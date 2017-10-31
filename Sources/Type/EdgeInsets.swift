//
//  EdgeInsets.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 13..
//  Copyright © 2017년 test. All rights reserved.
//

#if !os(OSX)
    import UIKit
#else
    import AppKit
#endif

public struct EdgeInsets {
    public var top: CGFloat
    public var left: CGFloat
    public var bottom: CGFloat
    public var right: CGFloat
    
    public var vertical: CGFloat {
        get {
            return self.top + self.bottom
        }
    }
    public var horizontal: CGFloat {
        get {
            return self.left + self.right
        }
    }
    
    public static var zero: EdgeInsets {
        get {
            return EdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    public init() {
        self.top = 0
        self.left = 0
        self.bottom = 0
        self.right = 0
    }
    public init(top: CGFloat, left: CGFloat, bottom: CGFloat, right: CGFloat) {
        self.top = top
        self.left = left
        self.bottom = bottom
        self.right = right
    }
}
