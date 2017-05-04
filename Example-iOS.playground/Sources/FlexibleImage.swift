//
//  FlexibleImage.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 3..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

#if !os(OSX)
    import UIKit
    public typealias Image = UIImage
    public typealias Color = UIColor
    public typealias BezierPath = UIBezierPath
#else
    import AppKit
    public typealias Image = NSImage
    public typealias Color = NSColor
    public typealias BezierPath = NSBezierPath
    
    extension NSImage {
        fileprivate var cgImage: CGImage? {
            get {
                return self.cgImage(forProposedRect: nil, context: nil, hints: nil)
            }
        }
    }
    
    extension NSBezierPath {
        fileprivate var cgPath: CGPath {
            let path = CGMutablePath()
            var points = [CGPoint](repeating: .zero, count: 3)
            
            for i in 0 ..< self.elementCount {
                let type = self.element(at: i, associatedPoints: &points)
                switch type {
                case .moveToBezierPathElement:
                    path.move(to: points[0])
                case .lineToBezierPathElement:
                    path.addLine(to: points[0])
                case .curveToBezierPathElement:
                    path.addCurve(to: points[2], control1: points[0], control2: points[1])
                case .closePathBezierPathElement:
                    path.closeSubpath()
                }
            }
            
            return path
        }
    }
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
    
    public func clipPath(_ rect: CGRect) -> BezierPath {
        if self.isZero() {
            
            return BezierPath(rect: rect)
            
        } else if self.isUniform() {
            
            #if !os(OSX)
                return UIBezierPath(roundedRect: rect, cornerRadius: self.topLeft)
            #else
                return NSBezierPath(roundedRect: rect, xRadius: self.topLeft, yRadius: self.topLeft)
            #endif
            
            
        } else {
            let cornerPath = BezierPath()
            
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
public struct EdgeInsets {
    public var top: CGFloat
    public var left: CGFloat
    public var bottom: CGFloat
    public var right: CGFloat
    
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

open class ImageChain {
    
    // MARK: - Type
    
    public struct ColorType {
        public var r: UInt16
        public var g: UInt16
        public var b: UInt16
        public var a: UInt16
        
        public init(_ colorType: ColorType) {
            self.r = colorType.r
            self.g = colorType.g
            self.b = colorType.b
            self.a = colorType.a
        }
        public init(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: UInt8) {
            self.r = UInt16(r)
            self.g = UInt16(g)
            self.b = UInt16(b)
            self.a = UInt16(a)
        }
        public init(_ r: UInt16, _ g: UInt16, _ b: UInt16, _ a: UInt16) {
            self.r = r
            self.g = g
            self.b = b
            self.a = a
        }
    }
    
    public typealias AlgorithmType = (_ x: Int, _ y: Int, _ color: ColorType) -> ColorType
    public typealias LayerType = (context: CGContext, spaceRect: CGRect, width: Int, height: Int, memoryPool: UnsafeMutablePointer<UInt8>)
    
    
    // MARK: - Internal
    
    private var saveImage: Image
    
    private var spaceSize: CGSize
    private var isAlphaBlend: Bool = false
    
    private var offset: CGPoint
    private var scale: CGSize?
    private var rotate: CGFloat?
    private var blendMode: CGBlendMode = .normal
    private var alpha: CGFloat = 1.0
    
    private var clipCorner: CornerType = CornerType(0)
    
    private var margin: EdgeInsets = .zero
    private var padding: EdgeInsets = .zero
    
    private var beforeLayer: [(LayerType)->Void] = []
    private var afterLayer: [(LayerType)->Void] = []
    private var lastLayer: [(LayerType)->Void] = []
    
    
    // MARK: - Public
    
    /// Common
    public func alpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }
    public func alphaBlend(_ isAlphaBlend: Bool) -> Self {
        self.isAlphaBlend = isAlphaBlend
        return self
    }
    public func blendMode(_ blendMode: CGBlendMode) -> Self {
        self.blendMode = blendMode
        return self
    }
    
    public func offset(_ offset: CGPoint) -> Self {
        self.offset = offset
        return self
    }
    public func size(_ size: CGSize) -> Self {
        self.scale = size
        return self
    }
    public func rotate(_ radius: CGFloat, _ fixedSize: CGSize? = nil) -> Self {
        self.rotate = (self.rotate ?? 0) + radius
        
        let size = self.scale ?? self.saveImage.size
        let sinValue = CGFloat(sinf(Float(self.rotate!)))
        let cosValue = CGFloat(cosf(Float(self.rotate!)))
        
        self.scale = size
        
        let rotateScale = CGSize(
            width: size.width * cosValue + size.height * sinValue,
            height: size.width * sinValue + size.height * cosValue
        )
        
        if let fixedSize = fixedSize {
            self.scale = CGSize(
                width: fixedSize.width * size.width / rotateScale.width,
                height: fixedSize.height * size.height / rotateScale.height
            )
            
            return self.outputSize(
                CGSize(
                    width: max(self.spaceSize.width, fixedSize.width),
                    height: max(self.spaceSize.height, fixedSize.height)
                )
            )
        } else {
            return self.outputSize(
                CGSize(
                    width: max(self.spaceSize.width, rotateScale.width),
                    height: max(self.spaceSize.height, rotateScale.height)
                )
            )
        }
    }
    public func outputSize(_ size: CGSize) -> Self {
        self.spaceSize = CGSize(
            width: size.width - self.margin.left - self.margin.right - self.padding.left - self.padding.right,
            height: size.height - self.margin.top - self.margin.bottom - self.padding.top - self.padding.bottom
        )
        
        return self
    }
    public func scaling(_ size: CGSize) -> Self {
        self.spaceSize.width *= size.width
        self.spaceSize.height *= size.height
        
        if self.scale != nil {
            self.scale!.width *= size.width
            self.scale!.height *= size.height
        }
        
        return self
    }
    public func margin(_ margin: EdgeInsets) -> Self {
        self.spaceSize = CGSize(
            width: self.spaceSize.width + self.margin.left + self.margin.right + self.padding.left + self.padding.right,
            height: self.spaceSize.height + self.margin.top + self.margin.bottom + self.padding.top + self.padding.bottom
        )
        
        self.margin = margin
        
        return self.outputSize(self.spaceSize)
    }
    public func padding(_ padding: EdgeInsets) -> Self {
        self.spaceSize = CGSize(
            width: self.spaceSize.width + self.margin.left + self.margin.right + self.padding.left + self.padding.right,
            height: self.spaceSize.height + self.margin.top + self.margin.bottom + self.padding.top + self.padding.bottom
        )
        
        self.padding = padding
        
        return self.outputSize(self.spaceSize)
    }
    public func corner(_ corner: CornerType) -> Self {
        self.clipCorner = corner
        return self
    }
    
    /// Before
    public func background(color: Color) -> Self {
        self.beforeLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.normal)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    
    /// After
    public func normal(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.normal)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func multiply(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.multiply)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func lighten(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.lighten)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func darken(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.darken)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func average(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = UInt16(CGFloat(cR + color.r) * 0.5)
            color.g = UInt16(CGFloat(cG + color.g) * 0.5)
            color.b = UInt16(CGFloat(cB + color.b) * 0.5)
            if self.isAlphaBlend {
                color.a = UInt16(CGFloat(cA + color.a) * 0.5)
            }
            
            return color
        }
    }
    public func add(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = min(255, cR + color.r)
            color.g = min(255, cG + color.g)
            color.b = min(255, cB + color.b)
            if self.isAlphaBlend {
                color.a = min(255, cA + color.a)
            }
            
            return color
        }
    }
    public func subtract(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        func subtract(_ a: UInt16, _ b: UInt16) -> UInt16 {
            if a + b < 255 {
                return 0
            } else {
                return a + b - 255
            }
        }
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = subtract(color.r, cR)
            color.g = subtract(color.g, cG)
            color.b = subtract(color.b, cB)
            if self.isAlphaBlend {
                color.a = subtract(color.a, cA)
            }
            
            return color
        }
    }
    public func difference(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.difference)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func negative(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = Int32(r * 255)
        let cG = Int32(g * 255)
        let cB = Int32(b * 255)
        let cA = Int32(a * 255)
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = 255 - min(255, UInt16(abs(255 - Int32(color.r) - cR)))
            color.g = 255 - min(255, UInt16(abs(255 - Int32(color.g) - cG)))
            color.b = 255 - min(255, UInt16(abs(255 - Int32(color.b) - cB)))
            if self.isAlphaBlend {
                color.a = 255 - min(255, UInt16(abs(255 - Int32(color.a) - cA)))
            }
            
            return color
        }
    }
    public func screen(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.screen)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
        
    }
    public func exclusion(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.exclusion)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func overlay(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.overlay)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func softLight(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.softLight)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func hardLight(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.hardLight)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func colorDodge(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.colorDodge)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func colorBurn(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.colorBurn)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func linearDodge(color: Color) -> Self {
        return self.add(color: color)
    }
    public func linearBurn(color: Color) -> Self {
        return self.subtract(color: color)
    }
    public func linearLight(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        func linearLight(_ a: UInt16, _ b: UInt16) -> UInt16 {
            if b < 128 {
                if a + 2 * b < 255 {
                    return 0
                } else {
                    return a + 2 * b - 255
                }
            } else {
                return min(255, UInt16(2 * (Int32(b) - 128) + Int32(a)))
            }
        }
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = linearLight(color.r, cR)
            color.g = linearLight(color.g, cG)
            color.b = linearLight(color.b, cB)
            if self.isAlphaBlend {
                color.a = linearLight(color.a, cA)
            }
            
            return color
        }
    }
    public func vividLight(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        func vividLight(_ a: UInt16, _ b: UInt16) -> UInt16 {
            if b < 128 {
                let a = (255 - a) << 8
                let b = 2 * b
                
                if b == 0 {
                    return b
                } else {
                    return max(0, 255 - min(255, a / b))
                }
            } else {
                let a = a << 8
                let b = 2 * (b - 128)
                
                if b == 255 {
                    return b
                } else {
                    return min(255, a / (255 - b))
                }
            }
        }
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = vividLight(color.r, cR)
            color.g = vividLight(color.g, cG)
            color.b = vividLight(color.b, cB)
            if self.isAlphaBlend {
                color.a = vividLight(color.a, cA)
            }
            
            return color
        }
    }
    public func pinLight(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        func pinLight(_ a: UInt16, _ b: UInt16) -> UInt16 {
            if b < 128 {
                return min(2 * b, a)
            } else {
                let b = max(b, 128) - 128
                return max(2 * b, a)
            }
        }
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = pinLight(color.r, cR)
            color.g = pinLight(color.g, cG)
            color.b = pinLight(color.b, cB)
            if self.isAlphaBlend {
                color.a = pinLight(color.a, cA)
            }
            
            return color
        }
    }
    public func hardMix(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        func hardMix(_ a: UInt16, _ b: UInt16) -> UInt16 {
            var result: UInt16
            
            if b < 128 {
                let a = (255 - a) << 8
                let b = 2 * b
                
                if b == 0 {
                    result = b
                } else {
                    result = max(0, 255 - min(255, a / b))
                }
            } else {
                let a = a << 8
                let b = 2 * (max(b, 128) - 128)
                
                if b == 255 {
                    result = b
                } else {
                    result = min(255, a / (255 - b))
                }
            }
            
            if result < 128 {
                return 0
            } else {
                return 255
            }
        }
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = hardMix(color.r, cR)
            color.g = hardMix(color.g, cG)
            color.b = hardMix(color.b, cB)
            if self.isAlphaBlend {
                color.a = hardMix(color.a, cA)
            }
            
            return color
        }
    }
    public func reflect(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        func reflect(_ a: UInt16, _ b: UInt16) -> UInt16 {
            if b == 255 {
                return b
            } else {
                return min(255, a * a / (255 - b))
            }
        }
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = reflect(color.r, cR)
            color.g = reflect(color.g, cG)
            color.b = reflect(color.b, cB)
            if self.isAlphaBlend {
                color.a = reflect(color.a, cA)
            }
            
            return color
        }
    }
    public func glow(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        func glow(_ a: UInt16, _ b: UInt16) -> UInt16 {
            if a == 255 {
                return a
            } else {
                return min(255, b * b / (255 - a))
            }
        }
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = glow(color.r, cR)
            color.g = glow(color.g, cG)
            color.b = glow(color.b, cB)
            if self.isAlphaBlend {
                color.a = glow(color.a, cA)
            }
            
            return color
        }
    }
    public func phoenix(color: Color) -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let cR = UInt16(r * 255)
        let cG = UInt16(g * 255)
        let cB = UInt16(b * 255)
        let cA = UInt16(a * 255)
        
        func phoenix(_ a: UInt16, _ b: UInt16) -> UInt16 {
            let first = min(a, b)
            let second = max(a, b)
            return first + 255 - second
        }
        
        return self.algorithm { [unowned self] x, y, c -> ColorType in
            var color = c
            color.r = phoenix(color.r, cR)
            color.g = phoenix(color.g, cG)
            color.b = phoenix(color.b, cB)
            if self.isAlphaBlend {
                color.a = phoenix(color.a, cA)
            }
            
            return color
        }
    }
    public func hue(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.hue)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func saturation(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.saturation)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func color(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.color)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func luminosity(color: Color) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.luminosity)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    
    /// Effect
    public func greyscale() -> Self {
        return self.algorithm { x, y, c -> ColorType in
            var color = c
            if color.a > 0 {
                color.r = UInt16(CGFloat(color.r) * 0.299 + CGFloat(color.g) * 0.587 + CGFloat(color.b) * 0.114)
                color.g = color.r
                color.b = color.r
            }
            
            return color
        }
    }
    public func monochrome() -> Self {
        func monochrome(_ l: CGFloat, _ d: CGFloat) -> UInt16 {
            if l < 128 {
                return UInt16(2.0 * l * d)
            } else {
                let l = 255 - l
                let d = 1.0 - d
                return 255 - UInt16(2.0 * l * d)
            }
        }
        
        return self.algorithm { x, y, c -> ColorType in
            var color = c
            let luminance = min(255.0, CGFloat(color.r) * 0.2125 + CGFloat(color.g) * 0.7154 + CGFloat(color.b) * 0.0721)
            
            if color.a > 0 {
                color.r = monochrome(luminance, 0.6)
                color.g = monochrome(luminance, 0.45)
                color.b = monochrome(luminance, 0.3)
            }
            
            return color
        }
    }
    public func invert() -> Self {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        return self.algorithm { x, y, c -> ColorType in
            var color = c
            if color.a == 0 {
                r = 0
                g = 0
                b = 0
                a = 0
            } else {
                a = CGFloat(color.a)
                r = CGFloat(color.r) / a
                g = CGFloat(color.g) / a
                b = CGFloat(color.b) / a
            }
            
            color.r = UInt16(max(0, (1.0 - r) * a))
            color.g = UInt16(max(0, (1.0 - g) * a))
            color.b = UInt16(max(0, (1.0 - b) * a))
            
            return color
        }
    }
    public func sepia() -> Self {
        return self.algorithm { x, y, c -> ColorType in
            var color = c
            if color.a > 0 {
                color.r = UInt16(CGFloat(color.r) * 0.393 + CGFloat(color.g) * 0.769 + CGFloat(color.b) * 0.189)
                color.g = UInt16(CGFloat(color.r) * 0.349 + CGFloat(color.g) * 0.686 + CGFloat(color.b) * 0.168)
                color.b = UInt16(CGFloat(color.r) * 0.272 + CGFloat(color.g) * 0.534 + CGFloat(color.b) * 0.131)
            }
            
            return color
        }
    }
    public func vibrance(_ vibrance: CGFloat = 0.0) -> Self {
        let vibranceOffset = -vibrance * 3.0
        
        func calc(_ a: UInt16, _ mx: CGFloat, _ amt: CGFloat) -> UInt16 {
            let first = CGFloat(a) * (1.0 - amt)
            let second = mx * amt
            return UInt16(first + second)
        }
        
        return self.algorithm { x, y, c -> ColorType in
            var color = c
            let avg = CGFloat(color.r + color.g + color.b) / 3.0
            let mx = CGFloat(max(color.r, max(color.g, color.b)))
            let amt = (mx - avg) / 255.0 * vibranceOffset
            
            if color.a > 0 {
                color.r = calc(color.r, mx, amt)
                color.g = calc(color.g, mx, amt)
                color.b = calc(color.b, mx, amt)
            }
            
            return color
        }
    }
    public func solarize(_ threshold: CGFloat = 0.5) -> Self {
        return self.algorithm { x, y, c -> ColorType in
            var color = c
            let l = CGFloat(color.r) * 0.2125 + CGFloat(color.g) * 0.7154 + CGFloat(color.b) * 0.0721
            let t = CGFloat((threshold >= l) ? 255 : 0)
            
            if color.a > 0 {
                color.r = UInt16(fabs(t - CGFloat(color.r)))
                color.g = UInt16(fabs(t - CGFloat(color.g)))
                color.b = UInt16(fabs(t - CGFloat(color.b)))
            }
            
            return color
        }
    }
    public func posterize(_ colorLevel: CGFloat = 10.0) -> Self {
        func posterize(_ a: UInt16) -> UInt16 {
            let first = CGFloat(a) * colorLevel / 255.0 + 0.5
            let second = floor(first) / colorLevel
            return UInt16(second * 255.0)
        }
        
        return self.algorithm { x, y, c -> ColorType in
            var color = c
            if color.a > 0 {
                color.r = posterize(color.r)
                color.g = posterize(color.g)
                color.b = posterize(color.b)
            }
            
            return color
        }
    }
    
    /// Etc
    public func append(_ imageChain: ImageChain) -> Self {
        return self.append(image: imageChain.image()!)
    }
    public func append(image: Image, offset: CGPoint = .zero, size: CGSize? = nil) -> Self {
        var size = size
        if size == nil {
            size = image.size
        }
        
        self.outputSize(
            CGSize(
                width: max(self.spaceSize.width, size!.width + offset.x),
                height: max(self.spaceSize.height, size!.width + offset.y)
            )
            ).lastLayer.append { context, spaceRect, _, _, _ in
                #if !os(OSX)
                    let scale = self.saveImage.scale
                #else
                    let scale = CGFloat(1.0)
                #endif
                
                image.draw(
                    in: CGRect(
                        x: offset.x * scale,
                        y: offset.y * scale,
                        width: size!.width * scale,
                        height: size!.height * scale
                    )
                )
        }
        return self
    }
    public func border(color: Color, lineWidth: CGFloat, radius: CGFloat) -> Self {
        self.lastLayer.append { context, spaceRect, _, _, _ in
            #if !os(OSX)
                let scale = self.saveImage.scale
            #else
                let scale = CGFloat(1.0)
            #endif
            
            let path: BezierPath
            
            let size = self.scale ?? self.spaceSize
            let rect = CGRect(
                x: (self.offset.x + self.margin.left) * scale,
                y: (self.offset.y + self.margin.top) * scale,
                width: (size.width + self.padding.left + self.padding.right) * scale,
                height: (size.height + self.padding.top + self.padding.bottom) * scale
            )
            
            if radius > 0 {
                #if !os(OSX)
                    path = UIBezierPath(roundedRect: rect, cornerRadius: radius * 2)
                #else
                    path = NSBezierPath(roundedRect: rect, xRadius: radius * 2, yRadius: radius * 2)
                #endif
            } else {
                path = BezierPath(rect: rect)
            }
            
            context.saveGState()
            
            context.setStrokeColor(color.cgColor)
            context.addPath(path.cgPath)
            context.setLineWidth(lineWidth)
            context.replacePathWithStrokedPath()
            context.drawPath(using: .stroke)
            
            context.restoreGState()
        }
        return self
    }
    
    /// Custom
    public func algorithm(_ algorithm: @escaping AlgorithmType) -> Self {
        self.afterLayer.append(self.generateAlgorithmClosure(algorithm: algorithm))
        return self
    }
    public func custom(_ layerBlock: @escaping ((LayerType)->Void)) -> Self {
        self.afterLayer.append(layerBlock)
        return self
    }
    
    /// Output
    public func image() -> Image? {
        /// Color Space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        /// Space Size
        #if !os(OSX)
            let scale = self.saveImage.scale
        #else
            let scale = CGFloat(1.0)
        #endif
        let width = Int((self.spaceSize.width + self.margin.left + self.margin.right + self.padding.left + self.padding.right) * scale)
        let height = Int((self.spaceSize.height + self.margin.top + self.margin.bottom + self.padding.top + self.padding.bottom) * scale)
        
        let spaceRect = CGRect(x: 0, y: 0, width: width, height: height)
        
        /// Alloc Memory
        let memorySize = width * height * 4
        let memoryPool = UnsafeMutablePointer<UInt8>.allocate(capacity: memorySize)
        defer { memoryPool.deallocate(capacity: memorySize) }
        memset(memoryPool, 0, memorySize)
        
        /// Create Context
        let context = CGContext(
            data: memoryPool,
            width: width, height: height, bitsPerComponent: 8, bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        )
        
        /// Push Context
        guard let drawContext = context else { return nil }
        
        #if !os(OSX)
            UIGraphicsBeginImageContext(spaceRect.size)
        #endif
        
        /// Corner Radius
        let cornerPath = self.clipCorner.clipPath(spaceRect)
        drawContext.addPath(cornerPath.cgPath)
        drawContext.clip()
        
        /// Before Layer
        self.beforeLayer.forEach { $0(LayerType(drawContext, spaceRect, width, height, memoryPool)) }
        
        /// Draw
        let size = self.scale ?? self.spaceSize
        
        drawContext.saveGState()
        drawContext.setBlendMode(self.blendMode)
        drawContext.setAlpha(self.alpha)
        
        if let rotateRadius = self.rotate {
            drawContext.translateBy(x: self.spaceSize.width * 0.5, y: self.spaceSize.height * 0.5)
            drawContext.rotate(by: rotateRadius)
            
            drawContext.draw(
                self.saveImage.cgImage!,
                in: CGRect(
                    x: (-size.width * 0.5 + (self.offset.x + self.margin.left + self.padding.left)) * scale,
                    y: (-size.height * 0.5 + (self.offset.y + self.margin.top + self.padding.top)) * scale,
                    width: size.width * scale,
                    height: size.height * scale
                )
            )
        } else {
            drawContext.draw(
                self.saveImage.cgImage!,
                in: CGRect(
                    x: (self.offset.x + self.margin.left + self.padding.left) * scale,
                    y: (self.offset.y + self.margin.top + self.padding.top) * scale,
                    width: size.width * scale,
                    height: size.height * scale
                )
            )
        }
        drawContext.restoreGState()
        
        /// After Layer
        drawContext.saveGState()
        if !self.isAlphaBlend {
            drawContext.clip(to: spaceRect, mask: drawContext.makeImage()!)
        }
        self.afterLayer.forEach { $0(LayerType(drawContext, spaceRect, width, height, memoryPool)) }
        drawContext.restoreGState()
        
        /// Last Layer
        self.lastLayer.forEach { $0(LayerType(drawContext, spaceRect, width, height, memoryPool)) }
        
        #if !os(OSX)
            UIGraphicsEndImageContext()
        #endif
        
        /// Convert Image
        if let cgImage = drawContext.makeImage() {
            #if !os(OSX)
                return Image(cgImage: cgImage, scale: scale, orientation: .up)
            #else
                return Image(cgImage: cgImage, size: spaceRect.size)
            #endif
        }
        
        return nil
    }
    
    
    // MARK: - Private
    
    private func generateAlgorithmClosure(
        algorithm: @escaping AlgorithmType
        ) -> ((LayerType)->Void) {
        return { _, _, width, height, memoryPool in
            
            var index = 0
            for y in 0..<height {
                for x in 0..<width {
                    let color = algorithm(
                        x,
                        y,
                        ColorType(
                            memoryPool[index + 0],
                            memoryPool[index + 1],
                            memoryPool[index + 2],
                            memoryPool[index + 3]
                        )
                    )
                    memoryPool[index + 0] = UInt8(min(color.r, 255))
                    memoryPool[index + 1] = UInt8(min(color.g, 255))
                    memoryPool[index + 2] = UInt8(min(color.b, 255))
                    memoryPool[index + 3] = UInt8(min(color.a, 255))
                    
                    index += 4
                }
            }
            
        }
    }
    
    
    // MARK: - Lifecycle
    
    fileprivate init(image: Image) {
        self.saveImage = image
        self.spaceSize = CGSize(
            width: self.saveImage.size.width,
            height: self.saveImage.size.height
        )
        
        self.offset = .zero
    }
    
}

extension Image {
    
    // MARK: - Public
    
    /// Generate
    public class func rect(color: Color, size: CGSize) -> Image? {
        let scale = Image.screenScale()
        
        let newSize: CGSize = CGSize(
            width: scale * size.width,
            height: scale * size.height
        )
        
        #if !os(OSX)
            UIGraphicsBeginImageContext(newSize)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
        #else
            guard let offscreenRep = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(newSize.width),
                pixelsHigh: Int(newSize.height),
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: NSDeviceRGBColorSpace,
                bitmapFormat: .alphaFirst,
                bytesPerRow: 0,
                bitsPerPixel: 0
                ) else { return nil }
            
            guard let graphicsContext = NSGraphicsContext(bitmapImageRep: offscreenRep) else { return nil }
            
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(graphicsContext)
            defer { NSGraphicsContext.restoreGraphicsState()}
            
            let context = graphicsContext.cgContext
        #endif
        
        context.clear(CGRect(origin: .zero, size: newSize))
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: newSize))
        
        #if !os(OSX)
            guard let imageContext = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            guard let cgImage = imageContext.cgImage else { return nil }
            
            return Image(
                cgImage: cgImage,
                scale: scale,
                orientation: .up
            )
        #else
            let image = Image(size: newSize)
            image.addRepresentation(offscreenRep)
            
            return image
        #endif
    }
    public class func circle(color: Color, size: CGSize) -> Image? {
        let scale = Image.screenScale()
        
        let newSize: CGSize = CGSize(
            width: scale * size.width,
            height: scale * size.height
        )
        
        #if !os(OSX)
            UIGraphicsBeginImageContext(newSize)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
        #else
            guard let offscreenRep = NSBitmapImageRep(
                bitmapDataPlanes: nil,
                pixelsWide: Int(newSize.width),
                pixelsHigh: Int(newSize.height),
                bitsPerSample: 8,
                samplesPerPixel: 4,
                hasAlpha: true,
                isPlanar: false,
                colorSpaceName: NSDeviceRGBColorSpace,
                bitmapFormat: .alphaFirst,
                bytesPerRow: 0,
                bitsPerPixel: 0
                ) else { return nil }
            
            guard let graphicsContext = NSGraphicsContext(bitmapImageRep: offscreenRep) else { return nil }
            
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.setCurrent(graphicsContext)
            defer { NSGraphicsContext.restoreGraphicsState()}
            
            let context = graphicsContext.cgContext
        #endif
        
        context.clear(CGRect(origin: .zero, size: newSize))
        
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: newSize))
        
        #if !os(OSX)
            guard let imageContext = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            guard let cgImage = imageContext.cgImage else { return nil }
            
            return Image(
                cgImage: cgImage,
                scale: scale,
                orientation: .up
            )
        #else
            let image = Image(size: newSize)
            image.addRepresentation(offscreenRep)
            
            return image
        #endif
    }
    
    /// Adjust
    public func adjust() -> ImageChain {
        return ImageChain(image: self)
    }
    
    
    // MARK: - Private
    
    private class func screenScale() -> CGFloat {
        // over iOS 8
        #if os(iOS)
            if #available(iOS 8, *) {
                return UIScreen.main.nativeScale
            }
            
            // over iOS 4
            if #available(iOS 4, *) {
                return UIScreen.main.scale
            }
        #endif
        
        return 1.0
    }
    
    
    // MARK: - Lifecycle
    
    public convenience init?(_ chain: ImageChain) {
        let image = chain.image()
        
        #if !os(OSX)
            self.init(cgImage: (image ?? Image.rect(color: .white, size: CGSize(width: 1, height: 1)))!.cgImage!)
        #else
            self.init(cgImage: (image ?? Image.rect(color: .white, size: CGSize(width: 1, height: 1)))!.cgImage!, size: CGSize(width: 1, height: 1))
        #endif
    }
    
}

public func +(lhs: Image?, rhs: Image?) -> Image? {
    guard let left = lhs else { return rhs }
    guard let right = rhs else { return lhs }
    
    return left.adjust().append(image: right).image()
}


