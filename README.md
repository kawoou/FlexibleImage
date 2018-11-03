<img alt="FlexibleImage" src="https://github.com/kawoou/FlexibleImage/raw/master/Preview/Cover.png" style="max-width: 100%">

<center>
<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-4.1-orange.svg">
  <a href="https://developer.apple.com/metal/" target="_blank"><img alt="Metal" src="https://img.shields.io/badge/Apple-Metal-ff00ff.svg"></a>
  <a href="http://cocoadocs.org/docsets/FlexibleImage" target="_blank"><img alt="Platform" src="http://img.shields.io/cocoapods/p/FlexibleImage.svg?style=flat"></a>
  <a href="https://github.com/kawoou/FlexibleImage/blob/master/LICENSE" target="_blank"><img alt="License" src="http://img.shields.io/cocoapods/l/FlexibleImage.svg?style=flat"></a>
  <br>
  <a href="https://travis-ci.org/kawoou/FlexibleImage" target="_blank"><img alt="Build Status" src="https://travis-ci.org/kawoou/FlexibleImage.svg?branch=master"></a>
  <a href="http://cocoadocs.org/docsets/FlexibleImage" target="_blank"><img alt="Version" src="http://img.shields.io/cocoapods/v/FlexibleImage.svg?style=flat"></a>
  <a href="https://github.com/Carthage/Carthage" target="_blank"><img alt="Carthage compatible" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"></a>
</p>
</center>

FlexibleImage is implemented with the hope that anyone could easily develop an app that provides features such as Camera Filter and Theme. When you write code in the "Method Chaining" style, the effect is applied in the appropriate order.

You may want to see [Examples](#-example) section first if you'd like to see the actual code.

<br>

💡 Usage
-----

### Code

![Example Image](https://github.com/kawoou/FlexibleImage/raw/master/Preview/Example.png)

```swift
import UIKit

import FlexibleImage

/// Generate Example
let image1 = UIImage
    .circle(
        color: UIColor.blue,
        size: CGSize(width: 100, height: 100)
    )!
    
    .adjust()
    .offset(CGPoint(x: 25, y: 0))
    .margin(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    .padding(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
    .normal(color: UIColor.white)
    .border(color: UIColor.red, lineWidth: 5, radius: 50)
    .image()!
    
    .adjust()
    .background(color: UIColor.darkGray)
    .image()


/// Effect Example
let image2 = UIImage(named: "macaron.jpg")!
    .adjust()
    .outputSize(CGSize(width: 250, height: 250))
    .exclusion(color: UIColor(red: 0, green: 0, blue: 0.352941176, alpha: 1.0))
    .linearDodge(color: UIColor(red: 0.125490196, green: 0.058823529, blue: 0.192156863, alpha: 1.0))
    .hardMix(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0))
    .image()


/// Mix Example
let image3 = image2!.adjust()
    .append(
        image1!.adjust()
            .outputSize(CGSize(width: 250, height: 250))
            .alpha(0.5)
    )
    .image()

/// Clipping Example
let image4 = image3!.adjust()
    .corner(CornerType(25))
    .image()

/// Pipeline
let pipeline = ImagePipeline()
        .exclusion(color: UIColor(red: 0, green: 0, blue: 0.352941176, alpha: 1.0))
        .linearDodge(color: UIColor(red: 0.125490196, green: 0.058823529, blue: 0.192156863, alpha: 1.0))

let image5 = pipeline.image(image2)
let image6 = pipeline.image(image1)
```


### Playground

Use CocoaPods command `$ pod try FlexibleImage` to try Playground!

<br>

🏗 Installation
------------

### [CocoaPods](https://cocoapods.org) (For iOS 8+ projects)

KWDrawerController is available on [CocoaPods](https://github.com/cocoapods/cocoapods). Add the following to your Podfile:

```ruby
/// Swift 3
pod 'FlexibleImage', '~> 1.7'

/// Swift 4
pod 'FlexibleImage', '~> 1.9'
```


### [Carthage](https://github.com/Carthage/Carthage) (For iOS 8+ projects)

```
github "kawoou/FlexibleImage" ~> 1.9
```


### Manually

You can either simply drag and drop the `Sources` folder into your existing project.

<br>

📕 Supported Features
------------------

### Common

| Type | Parameter | Comments |
| ---- | --------- | -------- |
| background() | Color | Background color. |
| opacity() | Float | Change the transparency of the image. |
| alphaProcess() | Bool | Whether to include an alpha value during image processing. |
| ~~blendMode()~~ | ~~CGBlendMode~~ | (Deprecated) ~~Blend mode of the image~~ |
| offset() | CGPoint | The position of the image to be a drawing. |
| rotate() | radius: CGFloat<br/>fixedSize: CGSize [Optional] | Rotate an image. |
| size() | CGSize | The size of the image to be a drawing. |
| outputSize() | CGSize | The size of a Output image. |
| scaling() | CGSize | Scaling the image (ratio) |
| margin() | EdgeInsets | Margin size |
| padding() | EdgeInsets | Padding size |
| corner() | CornerType | To clipping corner radius. |
| border() | color: Color<br/>lineWidth: CGFloat<br/>radius: CGFloat | Drawing a border. |
| image() | | Run the pipeline to create the Output image. |


### Filter

| Type | Parameter | Comments |
| ---- | --------- | -------- |
| greyscale() | threshold: Float [Optional] | |
| monochrome() | threshold: Float [Optional] | |
| invert() | | |
| sepia() | | |
| vibrance() | vibrance: Float [Optional] | |
| solarize() | threshold: Float [Optional] | |
| posterize() | colorLevel: Float [Optional] | |
| blur() | blurRadius: Float [Optional] | Not supported by watchOS. |
| brightness() | brightness: Float [Optional] | |
| chromaKey() | color: FIColor<br/>threshold: Float [Optional]<br/>smoothing: Float [Optional] | |
| swizzling() | | |
| contrast() | threshold: Float [Optional] | |
| gamma() | gamma: Float [Optional] | |


### Blend

| Type | Parameter |
| ---- | --------- |
| normal() | Color |
| multiply() | Color |
| lighten() | Color |
| darken() | Color |
| average() | Color |
| add() | Color |
| subtract() | Color |
| difference() | Color |
| negative() | Color |
| screen() | Color |
| exclusion() | Color |
| overlay() | Color |
| softLight() | Color |
| hardLight() | Color |
| colorDodge() | Color |
| colorBurn() | Color |
| linearDodge() | Color |
| linearBurn() | Color |
| linearLight() | Color |
| vividLight() | Color |
| pinLight() | Color |
| hardMix() | Color |
| reflect() | Color |
| glow() | Color |
| phoenix() | Color |
| hue() | Color |
| saturation() | Color |
| color() | Color |
| luminosity() | Color |


### Post-processing

| Type | Parameter | Comments |
| ---- | --------- | -------- |
| algorithm() | AlgorithmType | Create an image by writing a formula directly on a pixel-by-pixel basis. |
| custom() | ContextType | Add processing directly using Core Graphics. |


### Generate

| Type | Comments |
| ---- | -------- |
| rect() | Create a rectangular image. |
| circle() | Create a circle image. |
| append() | Combine images to create a single image. |


### Pipeline (`ImagePipeline` class)

| Type | Parameter | Return | Comments |
| ---- | --------- | ------ | -------- |
| image() | FIImage | FIImage? | Create the Output image. |
| image() | CGImage | CGImage? | Create the Output image. |
| image() | CVImageBuffer | CGImage? | Create the Output image. |

<br>

🎁 Example
-------

- [iOS APP Example](https://github.com/kawoou/FlexibleImage/tree/master/Example-app-iOS)
- [iOS Playground Example](https://github.com/kawoou/FlexibleImage/tree/master/Example-playground-iOS.playground)
- [macOS App Example](https://github.com/kawoou/FlexibleImage/tree/master/Example-app-macOS)
- [macOS Playground Example](https://github.com/kawoou/FlexibleImage/tree/master/Example-playground-macOS.playground)
- [tvOS App Example](https://github.com/kawoou/FlexibleImage/tree/master/Example-app-tvOS)
- [tvOS Playground Example](https://github.com/kawoou/FlexibleImage/tree/master/Example-playground-tvOS.playground)

<br>

🏷 Changelog
---------

+ 1.0
  - First Release.
+ 1.1
  - Add to clipping corner radius.
+ 1.2
  - Support tvOS, macOS.
+ 1.3
  - Support watchOS.
  - Added monochrome, sepia, vibrance, solarize, posterize filters.
  - Update resize methods.
+ 1.4
  - Add blur filter.
  - Optimize build time.
  - Setup TravisCI
  - Support carthage.
+ 1.5
  - Support Metal depending on the situation.
  - Added brightness, chromaKey, swizzling, contrast, gamma filters.
+ 1.6 (Hotfix!)
  - Fix issue Metal library path on Cocoapods.
+ 1.7
  - Pipelined implementation for stream processing.
  - Fix rendering bug due to image orientation (Thanks to Kwonyoon Kang)
+ 1.8
  - Support for Swift 4 and Xcode 9
+ 1.9
  - Support for Swift 4.1 and Xcode 9.3
+ 1.10
  - Support for Swift 4.2 and Xcode 10

<br>

💻 Requirements
------------

- iOS 8.0+
- tvOS 9.0+
- macOS 10.10+
- watchOS 2.0+
- Swift 3.0+

<br>

🔑 License
-------

FlexibleImage is under MIT license. See the LICENSE file for more info.


