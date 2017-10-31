//
//  FlexibleImage.swift
//  FlexibleImage
//
//  Created by Kawoou on 2017. 5. 3..
//  Copyright © 2017년 Kawoou. All rights reserved.
//

#if !os(OSX)
    import UIKit
#else
    import AppKit
#endif

#if !os(watchOS)
    import Accelerate
#endif

#if !os(watchOS)
    import Metal
    import CoreMedia
#endif

open class ImagePipeline: ImageChain {

    // MARK: - Public

    public func image(_ image: FIImage) -> FIImage? {
        /// Set Image
        self.device.image = image

        /// Output
        return super.image()
    }

    public func image(_ image: CGImage) -> CGImage? {
        /// Set Image
        self.device.cgImage = image
        self.device.imageScale = 1.0
        self.device.spaceSize = CGSize(
            width: image.width,
            height: image.height
        )

        self.device.beginGenerate(self.isAlphaProcess)
        self.filterList.forEach { filter in
            _ = filter.process(device: self.device)
        }
        return self.device.endGenerate()
    }
    
    #if !os(watchOS)
        public func image(_ buffer: CVImageBuffer) -> CGImage? {
            let width = CVPixelBufferGetWidth(buffer)
            let height = CVPixelBufferGetHeight(buffer)
            
            let ciImage: CIImage
            if #available(iOS 9.0, *) {
                ciImage = CIImage(cvImageBuffer: buffer)
            } else {
                ciImage = CIImage(cvPixelBuffer: buffer)
            }
            let ciContext: CIContext
            #if !os(watchOS)
                if #available(OSX 10.11, iOS 9, tvOS 9, *) {
                    if let device = self.device as? ImageMetalDevice {
                        ciContext = CIContext(mtlDevice: device.device)
                    } else {
                        ciContext = CIContext()
                    }
                } else {
                    ciContext = CIContext()
                }
            #endif
            
            let cgMakeImage = ciContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: width, height: height))
            guard let cgImage = cgMakeImage else { return nil }
            
            return self.image(cgImage)
        }
    #endif
    
    
    // MARK: - Lifecycle

    public init(isOnlyCoreGraphic: Bool = false) {
        super.init(image: nil, isOnlyCoreGraphic: isOnlyCoreGraphic)
    }

}

open class ImageChain {
    
    // MARK: - Internal
    
    fileprivate var device: ImageDevice
    
    fileprivate var saveSize: CGSize?
    
    fileprivate var isAlphaProcess: Bool = false
    
    fileprivate var filterList: [ImageFilter] = []
    
    
    // MARK: - Public
    
    /// Common
    public func background(color: FIColor) -> Self {
        self.device.background = color
        return self
    }
    public func opacity(_ opacity: CGFloat) -> Self {
        self.device.opacity = opacity
        return self
    }
    
    public func offset(_ offset: CGPoint) -> Self {
        self.device.offset = offset
        return self
    }
    public func size(_ size: CGSize) -> Self {
        self.device.scale = size
        return self
    }
    public func rotate(_ radius: CGFloat, _ fixedSize: CGSize? = nil) -> Self {
        self.device.rotate = (self.device.rotate ?? 0) + radius
        
        guard let saveSize = self.saveSize else { return self }

        let size = self.device.scale ?? saveSize
        let sinValue = CGFloat(sinf(Float(self.device.rotate!)))
        let cosValue = CGFloat(cosf(Float(self.device.rotate!)))
        
        self.device.scale = size
        
        let rotateScale = CGSize(
            width: size.width * cosValue + size.height * sinValue,
            height: size.width * sinValue + size.height * cosValue
        )
        
        if let fixedSize = fixedSize {
            self.device.scale = CGSize(
                width: fixedSize.width * size.width / rotateScale.width,
                height: fixedSize.height * size.height / rotateScale.height
            )
            
            return self.outputSize(
                CGSize(
                    width: max(self.device.spaceSize.width, fixedSize.width),
                    height: max(self.device.spaceSize.height, fixedSize.height)
                )
            )
        } else {
            return self.outputSize(
                CGSize(
                    width: max(self.device.spaceSize.width, rotateScale.width),
                    height: max(self.device.spaceSize.height, rotateScale.height)
                )
            )
        }
    }
    public func outputSize(_ size: CGSize) -> Self {
        self.device.spaceSize = CGSize(
            width: size.width - self.device.margin.left - self.device.margin.right - self.device.padding.left - self.device.padding.right,
            height: size.height - self.device.margin.top - self.device.margin.bottom - self.device.padding.top - self.device.padding.bottom
        )
        
        return self
    }
    public func scaling(_ size: CGSize) -> Self {
        self.device.spaceSize.width *= size.width
        self.device.spaceSize.height *= size.height
        
        if self.device.scale != nil {
            self.device.scale!.width *= size.width
            self.device.scale!.height *= size.height
        }
        
        return self
    }
    public func margin(_ margin: EdgeInsets) -> Self {
        self.device.spaceSize = CGSize(
            width: self.device.spaceSize.width + self.device.margin.left + self.device.margin.right + self.device.padding.left + self.device.padding.right,
            height: self.device.spaceSize.height + self.device.margin.top + self.device.margin.bottom + self.device.padding.top + self.device.padding.bottom
        )
        
        self.device.margin = margin
        
        return self.outputSize(self.device.spaceSize)
    }
    public func padding(_ padding: EdgeInsets) -> Self {
        self.device.spaceSize = CGSize(
            width: self.device.spaceSize.width + self.device.margin.left + self.device.margin.right + self.device.padding.left + self.device.padding.right,
            height: self.device.spaceSize.height + self.device.margin.top + self.device.margin.bottom + self.device.padding.top + self.device.padding.bottom
        )
        
        self.device.padding = padding
        
        return self.outputSize(self.device.spaceSize)
    }
    public func corner(_ corner: CornerType) -> Self {
        self.device.corner = corner
        return self
    }
    public func border(color: FIColor, lineWidth: CGFloat, radius: CGFloat) -> Self {
        self.device.border = (color, lineWidth, radius)
        return self
    }
    
    public func alphaProcess(_ isAlphaProcess: Bool) -> Self {
        self.isAlphaProcess = isAlphaProcess
        return self
    }
    
    /// Blend
    public func normal(color: FIColor) -> Self {
        let filter = NormalFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
    
        self.filterList.append(filter)
        return self
    }
    public func multiply(color: FIColor) -> Self {
        let filter = MultiplyFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func lighten(color: FIColor) -> Self {
        let filter = LightenFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func darken(color: FIColor) -> Self {
        let filter = DarkenFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func average(color: FIColor) -> Self {
        let filter = AverageFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func add(color: FIColor) -> Self {
        let filter = AddFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func subtract(color: FIColor) -> Self {
        let filter = SubtractFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func difference(color: FIColor) -> Self {
        let filter = DifferenceFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func negative(color: FIColor) -> Self {
        let filter = NegativeFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func screen(color: FIColor) -> Self {
        let filter = ScreenFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func exclusion(color: FIColor) -> Self {
        let filter = ExclusionFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.5
        }
        
        self.filterList.append(filter)
        return self
    }
    public func overlay(color: FIColor) -> Self {
        let filter = OverlayFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func softLight(color: FIColor) -> Self {
        let filter = SoftLightFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func hardLight(color: FIColor) -> Self {
        let filter = HardLightFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func colorDodge(color: FIColor) -> Self {
        let filter = ColorDodgeFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func colorBurn(color: FIColor) -> Self {
        let filter = ColorBurnFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func linearDodge(color: FIColor) -> Self {
        let filter = LinearDodgeFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func linearBurn(color: FIColor) -> Self {
        let filter = LinearBurnFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func linearLight(color: FIColor) -> Self {
        let filter = LinearLightFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.5
        }
        
        self.filterList.append(filter)
        return self
    }
    public func vividLight(color: FIColor) -> Self {
        let filter = VividLightFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.5
        }
        
        self.filterList.append(filter)
        return self
    }
    public func pinLight(color: FIColor) -> Self {
        let filter = PinLightFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.5
        }
        
        self.filterList.append(filter)
        return self
    }
    public func hardMix(color: FIColor) -> Self {
        let filter = HardMixFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.5
        }
        
        self.filterList.append(filter)
        return self
    }
    public func reflect(color: FIColor) -> Self {
        let filter = ReflectFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 0.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func glow(color: FIColor) -> Self {
        let filter = GlowFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func phoenix(color: FIColor) -> Self {
        let filter = PhoenixFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func hue(color: FIColor) -> Self {
        let filter = HueFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func saturation(color: FIColor) -> Self {
        let filter = SaturationFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func color(color: FIColor) -> Self {
        let filter = ColorFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    public func luminosity(color: FIColor) -> Self {
        let filter = LuminosityFilter(device: self.device)
        filter.color = color.imageColor
        if self.isAlphaProcess == false {
            filter.color.a = 1.0
        }
        
        self.filterList.append(filter)
        return self
    }
    
    /// Filter
    public func greyscale(_ threshold: Float = 1.0) -> Self {
        let filter = GreyscaleFilter(device: self.device)
        filter.threshold = threshold
        
        self.filterList.append(filter)
        return self
    }
    public func monochrome(_ threshold: Float = 1.0) -> Self {
        let filter = MonochromeFilter(device: self.device)
        filter.threshold = threshold
        
        self.filterList.append(filter)
        return self
    }
    public func invert() -> Self {
        let filter = InvertFilter(device: self.device)
        self.filterList.append(filter)
        return self
    }
    public func sepia() -> Self {
        let filter = SepiaFilter(device: self.device)
        self.filterList.append(filter)
        return self
    }
    public func vibrance(_ vibrance: Float = 5.0) -> Self {
        let filter = VibranceFilter(device: self.device)
        filter.vibrance = vibrance
        
        self.filterList.append(filter)
        return self
    }
    public func solarize(_ threshold: Float = 0.5) -> Self {
        let filter = SolarizeFilter(device: self.device)
        filter.threshold = threshold
        
        self.filterList.append(filter)
        return self
    }
    public func posterize(_ colorLevel: Float = 10.0) -> Self {
        let filter = PosterizeFilter(device: self.device)
        filter.colorLevel = colorLevel
        
        self.filterList.append(filter)
        return self
    }
    #if !os(watchOS)
    public func blur(_ blurRadius: Float = 20.0) -> Self {
        let filter = BlurFilter(device: self.device)
        filter.radius = blurRadius
        
        self.filterList.append(filter)
        return self
    }
    #endif
    public func brightness(_ brightness: Float = 0.5) -> Self {
        let filter = BrightnessFilter(device: self.device)
        filter.brightness = brightness
        
        self.filterList.append(filter)
        return self
    }
    public func chromaKey(color: FIColor, _ threshold: Float = 0.4, _ smoothing: Float = 0.1) -> Self {
        let filter = ChromaKeyFilter(device: self.device)
        filter.color = color.imageColor
        filter.threshold = threshold
        filter.smoothing = smoothing
        
        self.filterList.append(filter)
        return self
    }
    public func swizzling() -> Self {
        let filter = SwizzlingFilter(device: self.device)
        self.filterList.append(filter)
        return self
    }
    public func contrast(_ threshold: Float = 0.5) -> Self {
        let filter = ContrastFilter(device: self.device)
        filter.threshold = threshold
        
        self.filterList.append(filter)
        return self
    }
    public func gamma(_ gamma: Float = 1.0) -> Self {
        let filter = GammaFilter(device: self.device)
        filter.gamma = gamma
        
        self.filterList.append(filter)
        return self
    }
    
    /// Etc
    public func append(_ imageChain: ImageChain) -> Self {
        return self.append(image: imageChain.image()!)
    }
    public func append(image: FIImage, offset: CGPoint = .zero, resize: CGSize? = nil, _ threshold: Float = 1.0) -> Self {
        let scale = self.device.imageScale
        
        guard let imageRef = image.cgImage else { return self }
        
        let filter = TextureAppendFilter(device: self.device)
        filter.image = image
        filter.offsetX = Float(offset.x)
        filter.offsetY = Float(offset.y)
        filter.threshold = threshold
        if let resize = resize {
            filter.scaleX = Float(CGFloat(imageRef.width) / resize.width) * Float(scale / image.scale)
            filter.scaleY = Float(CGFloat(imageRef.height) / resize.height) * Float(scale / image.scale)
        } else {
            filter.scaleX = Float(scale / image.scale)
            filter.scaleY = Float(scale / image.scale)
        }
        self.filterList.append(filter)
        
        var size = resize
        if size == nil {
            size = image.size
        }
        
        return self.outputSize(
            CGSize(
                width: max(self.device.spaceSize.width, size!.width + offset.x),
                height: max(self.device.spaceSize.height, size!.width + offset.y)
            )
        )
    }
    
    /// Post-processing
    public func algorithm(_ algorithm: @escaping AlgorithmType) -> Self {
        self.device.postProcessList.append { _, width, height, memoryPool in
            var index = 0
            for y in 0..<height {
                for x in 0..<width {
                    let r = Float(memoryPool[index + 0]) / 255.0
                    let g = Float(memoryPool[index + 1]) / 255.0
                    let b = Float(memoryPool[index + 2]) / 255.0
                    let a = Float(memoryPool[index + 3]) / 255.0
                    
                    let inColor = FIColorType(r, g, b, a)
                    let outColor = algorithm(y, x, inColor, width, height, memoryPool)
                    
                    memoryPool[index + 0] = UInt8(max(min(outColor.r, 1.0), 0.0) * 255.0)
                    memoryPool[index + 1] = UInt8(max(min(outColor.g, 1.0), 0.0) * 255.0)
                    memoryPool[index + 2] = UInt8(max(min(outColor.b, 1.0), 0.0) * 255.0)
                    memoryPool[index + 3] = UInt8(max(min(outColor.a, 1.0), 0.0) * 255.0)
                    
                    index += 4
                }
            }
        }
        return self
    }
    public func custom(_ contextBlock: @escaping ContextType) -> Self {
        self.device.postProcessList.append(contextBlock)
        return self
    }
    
    /// Output
    public func image() -> FIImage? {
        let scale = self.device.imageScale
        
        self.device.beginGenerate(self.isAlphaProcess)
        
        self.filterList.forEach { filter in
            _ = filter.process(device: self.device)
        }
        
        if let cgImage = self.device.endGenerate() {
            #if !os(OSX)
                return FIImage(cgImage: cgImage, scale: scale, orientation: .up)
            #else
                return FIImage(cgImage: cgImage, size: CGSize(width: cgImage.width, height: cgImage.height))
            #endif
        }
        return nil
    }
    
    /// Deprecated
    @available(*, unavailable, renamed: "opacity()")
    public func alpha(_ alpha: CGFloat) -> Self {
        return self.opacity(alpha)
    }
    @available(*, unavailable, renamed: "alphaProcess()")
    public func alphaBlend(_ isAlphaBlend: Bool) -> Self {
        return self.alphaProcess(isAlphaBlend)
    }
    @available(*, unavailable, message: "Don't use")
    public func blendMode(_ blendMode: CGBlendMode) -> Self {
        return self
    }
    
    
    // MARK: - Lifecycle
    
    fileprivate init(image: FIImage?, isOnlyCoreGraphic: Bool = false) {
        if isOnlyCoreGraphic {
            self.device = ImageNoneDevice()
        } else {
            #if !os(watchOS)
                if #available(OSX 10.11, *) {
                    if let _ = MTLCreateSystemDefaultDevice() {
                        self.device = ImageMetalDevice()
                    } else {
                        self.device = ImageNoneDevice()
                    }
                } else {
                    self.device = ImageNoneDevice()
                }
            #else
                self.device = ImageNoneDevice()
            #endif
        }

        guard let image = image else { return }

        self.device.image = image
        self.saveSize = CGSize(
            width: image.size.width,
            height: image.size.height
        )
    }
    
}

extension FIImage {
    
    // MARK: - Public
    
    /// Generate
    public class func rect(color: FIColor, size: CGSize) -> FIImage? {
        let scale = FIImage.screenScale()
        
        let newSize: CGSize = CGSize(
            width: scale * size.width,
            height: scale * size.height
        )
        
        #if !os(OSX)
            UIGraphicsBeginImageContext(newSize)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
        #else
            #if swift(>=4.0)
                guard let offscreenRep = NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: Int(newSize.width),
                    pixelsHigh: Int(newSize.height),
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: NSColorSpaceName.deviceRGB,
                    bitmapFormat: .alphaFirst,
                    bytesPerRow: 0,
                    bitsPerPixel: 0
                ) else { return nil }
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
            #endif
            
            guard let graphicsContext = NSGraphicsContext(bitmapImageRep: offscreenRep) else { return nil }
            
            NSGraphicsContext.saveGraphicsState()
            #if swift(>=4.0)
            NSGraphicsContext.current = graphicsContext
            #else
            NSGraphicsContext.setCurrent(graphicsContext)
            #endif
            defer { NSGraphicsContext.restoreGraphicsState() }
            
            let context = graphicsContext.cgContext
        #endif
        
        context.clear(CGRect(origin: .zero, size: newSize))
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: newSize))
        
        #if !os(OSX)
            guard let imageContext = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            guard let cgImage = imageContext.cgImage else { return nil }
            
            return FIImage(
                cgImage: cgImage,
                scale: scale,
                orientation: .up
            )
        #else
            let image = FIImage(size: newSize)
            image.addRepresentation(offscreenRep)
            
            return image
        #endif
    }
    public class func circle(color: FIColor, size: CGSize) -> FIImage? {
        let scale = FIImage.screenScale()
        
        let newSize: CGSize = CGSize(
            width: scale * size.width,
            height: scale * size.height
        )
        
        #if !os(OSX)
            UIGraphicsBeginImageContext(newSize)
            defer { UIGraphicsEndImageContext() }
            
            guard let context = UIGraphicsGetCurrentContext() else { return nil }
        #else
            #if swift(>=4.0)
                guard let offscreenRep = NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: Int(newSize.width),
                    pixelsHigh: Int(newSize.height),
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: NSColorSpaceName.deviceRGB,
                    bitmapFormat: .alphaFirst,
                    bytesPerRow: 0,
                    bitsPerPixel: 0
                ) else { return nil }
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
            #endif
            
            guard let graphicsContext = NSGraphicsContext(bitmapImageRep: offscreenRep) else { return nil }
            
            NSGraphicsContext.saveGraphicsState()
            #if swift(>=4.0)
                NSGraphicsContext.current = graphicsContext
            #else
                NSGraphicsContext.setCurrent(graphicsContext)
            #endif
            defer { NSGraphicsContext.restoreGraphicsState()}
            
            let context = graphicsContext.cgContext
        #endif
        
        context.clear(CGRect(origin: .zero, size: newSize))
        
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: newSize))
        
        #if !os(OSX)
            guard let imageContext = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
            guard let cgImage = imageContext.cgImage else { return nil }
            
            return FIImage(
                cgImage: cgImage,
                scale: scale,
                orientation: .up
            )
        #else
            let image = FIImage(size: newSize)
            image.addRepresentation(offscreenRep)
            
            return image
        #endif
    }
    
    /// Adjust
    public func adjust(_ isOnlyCoreGraphic: Bool = false) -> ImageChain {
        return ImageChain(image: self, isOnlyCoreGraphic: isOnlyCoreGraphic)
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
            self.init(cgImage: (image ?? FIImage.rect(color: .white, size: CGSize(width: 1, height: 1)))!.cgImage!)
        #else
            self.init(cgImage: (image ?? FIImage.rect(color: .white, size: CGSize(width: 1, height: 1)))!.cgImage!, size: CGSize(width: 1, height: 1))
        #endif
    }
    
}

public func +(lhs: FIImage?, rhs: FIImage?) -> FIImage? {
    guard let left = lhs else { return rhs }
    guard let right = rhs else { return lhs }
    
    return left.adjust().append(image: right).image()
}


