//
//  CornerType.swift
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

public struct CornerType {
    public var topLeft: CGFloat
    public var topRight: CGFloat
    public var bottomLeft: CGFloat
    public var bottomRight: CGFloat
    
    public func isUniform() -> Bool {
        if self.topLeft == self.topRight &&
            self.topRight == self.bottomLeft &&
            self.bottomLeft == self.bottomRight &&
            self.bottomRight > 0 {
            return true
        }
        return false
    }
    public func isZero() -> Bool {
        if self.topLeft == self.topRight &&
            self.topRight == self.bottomLeft &&
            self.bottomLeft == self.bottomRight &&
            self.bottomRight == 0 {
            return true
        }
        return false
    }
    
    public func clipPath(_ rect: CGRect) -> FIBezierPath {
        if self.isZero() {
            
            return FIBezierPath(rect: rect)
            
        } else if self.isUniform() {
            
            #if !os(OSX)
                return UIBezierPath(roundedRect: rect, cornerRadius: self.topLeft)
            #else
                return NSBezierPath(roundedRect: rect, xRadius: self.topLeft, yRadius: self.topLeft)
            #endif
            
            
        } else {
            let cornerPath = FIBezierPath()
            
            /// Top-Left
            let topLeftCenter = CGPoint(
                x: self.topLeft,
                y: self.topLeft
            )
            if self.topLeft > 0 {
                #if !os(OSX)
                    cornerPath.addArc(
                        withCenter: topLeftCenter,
                        radius: self.topLeft,
                        startAngle: CGFloat.pi,
                        endAngle: 1.5 * CGFloat.pi,
                        clockwise: true
                    )
                #else
                    cornerPath.appendArc(
                        withCenter: topLeftCenter,
                        radius: self.topLeft,
                        startAngle: CGFloat.pi,
                        endAngle: 1.5 * CGFloat.pi,
                        clockwise: true
                    )
                #endif
            } else {
                cornerPath.move(to: topLeftCenter)
            }
            
            /// Top-Right
            let topRightCenter = CGPoint(
                x: rect.width - self.topRight,
                y: self.topRight
            )
            if self.topRight > 0 {
                #if !os(OSX)
                    cornerPath.addArc(
                        withCenter: topRightCenter,
                        radius: self.topRight,
                        startAngle: 1.5 * CGFloat.pi,
                        endAngle: 2 * CGFloat.pi,
                        clockwise: true
                    )
                #else
                    cornerPath.appendArc(
                        withCenter: topRightCenter,
                        radius: self.topRight,
                        startAngle: 1.5 * CGFloat.pi,
                        endAngle: 2 * CGFloat.pi,
                        clockwise: true
                    )
                #endif
            } else {
                #if !os(OSX)
                    cornerPath.addLine(to: topRightCenter)
                #else
                    cornerPath.line(to: topRightCenter)
                #endif
            }
            
            /// Bottom-Right
            let bottomRightCenter = CGPoint(
                x: rect.width - self.bottomRight,
                y: rect.height - self.bottomRight
            )
            if self.bottomRight > 0 {
                #if !os(OSX)
                    cornerPath.addArc(
                        withCenter: bottomRightCenter,
                        radius: self.bottomRight,
                        startAngle: 2 * CGFloat.pi,
                        endAngle: 2.5 * CGFloat.pi,
                        clockwise: true
                    )
                #else
                    cornerPath.appendArc(
                        withCenter: bottomRightCenter,
                        radius: self.bottomRight,
                        startAngle: 2 * CGFloat.pi,
                        endAngle: 2.5 * CGFloat.pi,
                        clockwise: true
                    )
                #endif
            } else {
                #if !os(OSX)
                    cornerPath.addLine(to: bottomRightCenter)
                #else
                    cornerPath.line(to: bottomRightCenter)
                #endif
            }
            
            /// Bottom-Left
            let bottomLeftCenter = CGPoint(
                x: self.bottomLeft,
                y: rect.height - self.bottomLeft
            )
            if self.bottomLeft > 0 {
                #if !os(OSX)
                    cornerPath.addArc(
                        withCenter: bottomLeftCenter,
                        radius: self.bottomLeft,
                        startAngle: 2.5 * CGFloat.pi,
                        endAngle: 3 * CGFloat.pi,
                        clockwise: true
                    )
                #else
                    cornerPath.appendArc(
                        withCenter: bottomLeftCenter,
                        radius: self.bottomLeft,
                        startAngle: 2.5 * CGFloat.pi,
                        endAngle: 3 * CGFloat.pi,
                        clockwise: true
                    )
                #endif
            } else {
                #if !os(OSX)
                    cornerPath.addLine(to: bottomLeftCenter)
                #else
                    cornerPath.line(to: bottomLeftCenter)
                #endif
            }
            
            /// Top-Left
            #if !os(OSX)
                if self.topLeft > 0 {
                    cornerPath.addLine(to: CGPoint(x: 0, y: topLeftCenter.y))
                } else {
                    cornerPath.addLine(to: topLeftCenter)
                }
            #else
                if self.topLeft > 0 {
                    cornerPath.line(to: CGPoint(x: 0, y: topLeftCenter.y))
                } else {
                    cornerPath.line(to: topLeftCenter)
                }
            #endif
            
            return cornerPath
        }
    }
    
    public init(_ radius: CGFloat) {
        self.topLeft = radius
        self.topRight = radius
        self.bottomLeft = radius
        self.bottomRight = radius
    }
    
    public init(topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) {
        self.topLeft = topLeft
        self.topRight = topRight
        self.bottomLeft = bottomLeft
        self.bottomRight = bottomRight
    }
}
