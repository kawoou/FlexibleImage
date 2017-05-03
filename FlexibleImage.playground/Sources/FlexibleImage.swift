//
//  FlexibleImage.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 3..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

import UIKit

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
    
    public func clipPath(_ rect: CGRect) -> UIBezierPath {
        if self.isZero() {
            
            return  UIBezierPath(rect: rect)
            
        } else if self.isUniform() {
            
            return UIBezierPath(roundedRect: rect, cornerRadius: self.topLeft)
            
        } else {
            let cornerPath = UIBezierPath()
            
            /// Top-Left
            let topLeftCenter = CGPoint(
                x: self.topLeft,
                y: self.topLeft
            )
            if self.topLeft > 0 {
                cornerPath.addArc(
                    withCenter: topLeftCenter,
                    radius: self.topLeft,
                    startAngle: CGFloat.pi,
                    endAngle: 1.5 * CGFloat.pi,
                    clockwise: true
                )
            } else {
                cornerPath.move(to: topLeftCenter)
            }
            
            /// Top-Right
            let topRightCenter = CGPoint(
                x: rect.width - self.topRight,
                y: self.topRight
            )
            if self.topRight > 0 {
                cornerPath.addArc(
                    withCenter: topRightCenter,
                    radius: self.topRight,
                    startAngle: 1.5 * CGFloat.pi,
                    endAngle: 2 * CGFloat.pi,
                    clockwise: true
                )
            } else {
                cornerPath.addLine(to: topRightCenter)
            }
            
            /// Bottom-Right
            let bottomRightCenter = CGPoint(
                x: rect.width - self.bottomRight,
                y: rect.height - self.bottomRight
            )
            if self.bottomRight > 0 {
                cornerPath.addArc(
                    withCenter: bottomRightCenter,
                    radius: self.bottomRight,
                    startAngle: 2 * CGFloat.pi,
                    endAngle: 2.5 * CGFloat.pi,
                    clockwise: true
                )
            } else {
                cornerPath.addLine(to: bottomRightCenter)
            }
            
            /// Bottom-Left
            let bottomLeftCenter = CGPoint(
                x: self.bottomLeft,
                y: rect.height - self.bottomLeft
            )
            if self.bottomLeft > 0 {
                cornerPath.addArc(
                    withCenter: bottomLeftCenter,
                    radius: self.bottomLeft,
                    startAngle: 2.5 * CGFloat.pi,
                    endAngle: 3 * CGFloat.pi,
                    clockwise: true
                )
            } else {
                cornerPath.addLine(to: bottomLeftCenter)
            }
            
            /// Top-Left
            if self.topLeft > 0 {
                cornerPath.addLine(to: CGPoint(x: 0, y: topLeftCenter.y))
            } else {
                cornerPath.addLine(to: topLeftCenter)
            }
            
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

open class UIImageChain {
    
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
    
    private var saveImage: UIImage
    
    private var spaceSize: CGSize
    private var isAlphaBlend: Bool = false
    
    private var offset: CGPoint
    private var scale: CGSize?
    private var rotate: CGFloat?
    private var rotateScale: CGSize?
    private var blendMode: CGBlendMode = .normal
    private var alpha: CGFloat = 1.0
    
    private var clipCorner: CornerType = CornerType(0)
    
    private var margin: UIEdgeInsets = .zero
    private var padding: UIEdgeInsets = .zero
    
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
        self.rotateScale = size
        return self
    }
    public func rotate(_ radius: CGFloat) -> Self {
        self.rotate = (self.rotate ?? 0) + radius
        
        let size = self.scale ?? self.saveImage.size
        let rotateView = UIView(frame: CGRect(origin: .zero, size: size))
        rotateView.transform = CGAffineTransform(rotationAngle: radius)
        
        self.rotateScale = rotateView.frame.size
        
        return self.outputSize(
            CGSize(
                width: max(self.spaceSize.width, self.rotateScale!.width),
                height: max(self.spaceSize.height, self.rotateScale!.height)
            )
        )
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
        if self.rotateScale != nil {
            self.rotateScale!.width *= size.width
            self.rotateScale!.height *= size.height
        }
        
        return self
    }
    public func margin(_ margin: UIEdgeInsets) -> Self {
        self.spaceSize = CGSize(
            width: self.spaceSize.width + self.margin.left + self.margin.right + self.padding.left + self.padding.right,
            height: self.spaceSize.height + self.margin.top + self.margin.bottom + self.padding.top + self.padding.bottom
        )
        
        self.margin = margin
        
        return self.outputSize(self.spaceSize)
    }
    public func padding(_ padding: UIEdgeInsets) -> Self {
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
    public func background(color: UIColor) -> Self {
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
    public func normal(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.normal)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func multiply(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.multiply)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func lighten(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.lighten)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func darken(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.darken)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func average(color: UIColor) -> Self {
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
    public func add(color: UIColor) -> Self {
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
    public func subtract(color: UIColor) -> Self {
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
    public func difference(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.difference)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func negative(color: UIColor) -> Self {
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
    public func screen(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.screen)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
        
    }
    public func exclusion(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.exclusion)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func overlay(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.overlay)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func softLight(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.softLight)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func hardLight(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.hardLight)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func colorDodge(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.colorDodge)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func colorBurn(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.colorBurn)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func linearDodge(color: UIColor) -> Self {
        return self.add(color: color)
    }
    public func linearBurn(color: UIColor) -> Self {
        return self.subtract(color: color)
    }
    public func linearLight(color: UIColor) -> Self {
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
    public func vividLight(color: UIColor) -> Self {
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
    public func pinLight(color: UIColor) -> Self {
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
    public func hardMix(color: UIColor) -> Self {
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
    public func reflect(color: UIColor) -> Self {
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
    public func glow(color: UIColor) -> Self {
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
    public func phoenix(color: UIColor) -> Self {
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
    public func hue(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.hue)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func saturation(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.saturation)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func color(color: UIColor) -> Self {
        self.afterLayer.append { context, spaceRect, _, _, _ in
            context.saveGState()
            
            context.setBlendMode(.color)
            context.setFillColor(color.cgColor)
            context.fill(spaceRect)
            
            context.restoreGState()
        }
        return self
    }
    public func luminosity(color: UIColor) -> Self {
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
    
    /// Etc
    public func append(_ imageChain: UIImageChain) -> Self {
        return self.append(image: imageChain.image()!)
    }
    public func append(image: UIImage, offset: CGPoint = .zero, size: CGSize? = nil) -> Self {
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
                let scale = self.saveImage.scale
                
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
    public func border(color: UIColor, lineWidth: CGFloat, radius: CGFloat) -> Self {
        self.lastLayer.append { context, spaceRect, _, _, _ in
            let scale = self.saveImage.scale
            let path: UIBezierPath
            
            let size = self.scale ?? self.spaceSize
            let rect = CGRect(
                x: (self.offset.x + self.margin.left) * scale,
                y: (self.offset.y + self.margin.top) * scale,
                width: (size.width + self.padding.left + self.padding.right) * scale,
                height: (size.height + self.padding.top + self.padding.bottom) * scale
            )
            
            if radius > 0 {
                path = UIBezierPath(roundedRect: rect, cornerRadius: radius * 2)
            } else {
                path = UIBezierPath(rect: rect)
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
    public func image() -> UIImage? {
        /// Color Space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        /// Space Size
        let scale = self.saveImage.scale
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
        UIGraphicsPushContext(drawContext)
        
        /// Flip Vertical
        drawContext.concatenate(CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: CGFloat(height)))
        
        /// Corner Radius
        let cornerPath = self.clipCorner.clipPath(spaceRect)
        drawContext.addPath(cornerPath.cgPath)
        drawContext.clip()
        
        /// Before Layer
        self.beforeLayer.forEach { $0(LayerType(drawContext, spaceRect, width, height, memoryPool)) }
        
        /// Draw
        if let rotateRadius = self.rotate {
            let size = self.scale ?? self.rotateScale ?? self.spaceSize
            
            drawContext.saveGState()
            
            drawContext.translateBy(x: size.width * 0.5, y: size.height * 0.5)
            drawContext.rotate(by: rotateRadius)
            drawContext.scaleBy(x: 1.0, y: -1.0)
            
            self.saveImage.draw(
                in: CGRect(
                    x: (-size.width * 0.5 + (self.offset.x + self.margin.left + self.padding.left)) * scale,
                    y: (-size.height * 0.5 + (self.offset.y + self.margin.top + self.padding.top)) * scale,
                    width: size.width * scale,
                    height: size.height * scale
                ),
                blendMode: self.blendMode,
                alpha: self.alpha
            )
            
            drawContext.restoreGState()
        } else {
            let size = self.scale ?? self.spaceSize
            
            self.saveImage.draw(
                in: CGRect(
                    x: (self.offset.x + self.margin.left + self.padding.left) * scale,
                    y: (self.offset.y + self.margin.top + self.padding.top) * scale,
                    width: size.width * scale,
                    height: size.height * scale
                ),
                blendMode: self.blendMode,
                alpha: self.alpha
            )
        }
        
        /// After Layer
        drawContext.saveGState()
        
        if !self.isAlphaBlend {
            drawContext.clip(to: spaceRect, mask: drawContext.makeImage()!)
        }
        self.afterLayer.forEach { $0(LayerType(drawContext, spaceRect, width, height, memoryPool)) }
        
        drawContext.restoreGState()
        
        /// Last Layer
        self.lastLayer.forEach { $0(LayerType(drawContext, spaceRect, width, height, memoryPool)) }
        
        UIGraphicsPopContext()
        
        /// Convert Image
        if let cgImage = drawContext.makeImage() {
            return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
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
    
    fileprivate init(image: UIImage) {
        self.saveImage = image
        self.spaceSize = CGSize(
            width: self.saveImage.size.width,
            height: self.saveImage.size.height
        )
        
        self.offset = .zero
    }
    
}

extension UIImage {
    
    // MARK: - Public
    
    /// Generate
    public class func rect(color: UIColor, size: CGSize) -> UIImage? {
        let scale = UIImage.screenScale()
        
        let newSize: CGSize = CGSize(
            width: scale * size.width,
            height: scale * size.height
        )
        
        UIGraphicsBeginImageContext(newSize)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.clear(CGRect(origin: .zero, size: newSize))
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: newSize))
        
        guard let imageContext = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        guard let cgImage = imageContext.cgImage else { return nil }
        
        return UIImage(
            cgImage: cgImage,
            scale: scale,
            orientation: .up
        )
    }
    public class func circle(color: UIColor, size: CGSize) -> UIImage? {
        let scale = UIImage.screenScale()
        
        let newSize: CGSize = CGSize(
            width: scale * size.width,
            height: scale * size.height
        )
        
        UIGraphicsBeginImageContext(newSize)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        context.clear(CGRect(origin: .zero, size: newSize))
        
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: newSize))
        
        guard let imageContext = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        guard let cgImage = imageContext.cgImage else { return nil }
        
        return UIImage(
            cgImage: cgImage,
            scale: scale,
            orientation: .up
        )
    }
    
    /// Adjust
    public func adjust() -> UIImageChain {
        return UIImageChain(image: self)
    }
    
    
    // MARK: - Private
    
    private class func screenScale() -> CGFloat {
        // over iOS 8
        if #available(iOS 8, *) {
            return UIScreen.main.nativeScale
        }
        
        // over iOS 4
        if #available(iOS 4, *) {
            return UIScreen.main.scale
        }
        
        return 1.0
    }
    
    
    // MARK: - Lifecycle
    
    public convenience init?(_ chain: UIImageChain) {
        let image = chain.image()
        
        self.init(cgImage: (image ?? UIImage.rect(color: .white, size: CGSize(width: 1, height: 1)))!.cgImage!)
    }
    
}

public func +(lhs: UIImage?, rhs: UIImage?) -> UIImage? {
    guard let left = lhs else { return rhs }
    guard let right = rhs else { return lhs }
    
    return left.adjust().append(image: right).image()
}

