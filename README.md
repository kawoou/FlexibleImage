FlexibleImage
=============

![Swift](https://img.shields.io/badge/Swift-3.0-orange.svg)
[![Pod Version](http://img.shields.io/cocoapods/v/FlexibleImage.svg?style=flat)](http://cocoadocs.org/docsets/FlexibleImage/1.0)
[![Pod Platform](http://img.shields.io/cocoapods/p/FlexibleImage.svg?style=flat)](http://cocoadocs.org/docsets/FlexibleImage/1.0)
[![Pod License](http://img.shields.io/cocoapods/l/FlexibleImage.svg?style=flat)](https://github.com/kawoou/FlexibleImage/blob/master/LICENSE)

A simple way to play with image!


Installation
------------

### CocoaPods (For iOS 8+ projects)

KWDrawerController is available on [CocoaPods](https://github.com/cocoapods/cocoapods). Add the following to your Podfile:

```ruby
pod 'FlexibleImage', '~> 1.0'
```


### Manually

You can either simply drag and drop the `FlexibleImage` folder into your existing project.


Usage
-----

### Code

![Example Image](https://github.com/Kawoou/FlexibleImage/raw/master/Preview/Example.png)

```swift
import UIKit

import FlexibleImage

/// Generate Example
let image1 = UIImage
    .circle(
        color: UIColor.blue,
        size: CGSize(width: 100, height: 100)
    )?
    .adjust()
    .offset(CGPoint(x: 25, y: 0))
    .margin(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    .padding(UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
    .normal(color: UIColor.white)
    .border(color: UIColor.red, lineWidth: 5, radius: 50)
    .image()?
    .adjust()
    .background(color: UIColor.darkGray)
    .image()


/// Effect Example
let image2 = UIImage(named: "macaron.jpg")

let image3 = image2?.adjust()
    .outputSize(CGSize(width: 250, height: 250))
    .exclusion(color: UIColor(red: 0, green: 0, blue: 0.352941176, alpha: 1.0))
    .linearDodge(color: UIColor(red: 0.125490196, green: 0.058823529, blue: 0.192156863, alpha: 1.0))
    .image()

let image4 = image3?.adjust()
    .hardMix(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0))
    .image()


/// Mix Example
let image5 = image4?.adjust()
    .append(
        image1!.adjust()
            .outputSize(CGSize(width: 250, height: 250))
            .alpha(0.5)
    )
    .image()
```


Supported Features
------------------

### Common

| type | comments |
| ---- | -------- |
| alpha() | Change the transparency of the image. |
| alphaBlend() | Determines whether the calculation is applied to the alpha value. |
| blendMode() | Blend mode of the image |
| offset() | Position of the image to be drawn |
| size() | Size of the image to be drawn |
| outputSize() | Size of image to be output |
| rotate() | Rotate the image |
| scaling() | Scaling the image (ratio) |
| margin() | Margin size |
| padding() | Padding size |


### Before

| type | comments |
| ---- | -------- |
| background() | Background color |


### Generate

| type | comments |
| ---- | -------- |
| border() | Draw a border |
| rect() | Create a rectangular image |
| circle() | Create a circle image |
| append() | Combine images to create a single image. |

### Effects

- normal
- multiply
- lighten
- darken
- average
- add
- subtract
- difference
- negative
- screen
- exclusion
- overlay
- softLight
- hardLight
- colorDodge
- colorBurn
- linearDodge
- linearBurn
- linearLight
- vividLight
- pinLight
- hardMix
- reflect
- glow
- phoenix
- hue
- saturation
- color
- luminosity


- greyscale
- invert


Changelog
---------

+ 1.0 First Release.


Requirements
--------------

 - iOS 8.0+
 - Swift 3.0+


License
----------

FlexibleImage is under MIT license. See the LICENSE file for more info.
