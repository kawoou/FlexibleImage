import UIKit
import FlexibleImageTvOS

let image1 = UIImage
    .circle(
        color: UIColor.blue,
        size: CGSize(width: 100, height: 100)
    )?
    .adjust()
    .offset(CGPoint(x: 25, y: 0))
    .margin(EdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
    .padding(EdgeInsets(top: 15, left: 15, bottom: 15, right: 15))
    .normal(color: UIColor.white)
    .border(color: UIColor.red, lineWidth: 5, radius: 50)
    .image()?
    .adjust()
    .background(color: UIColor.darkGray)
    .image()

let image2 = UIImage(named: "macaron.jpg")

let image3 = image2?.adjust()
    .outputSize(CGSize(width: 250, height: 250))
    .exclusion(color: UIColor(red: 0, green: 0, blue: 0.352941176, alpha: 1.0))
    .linearDodge(color: UIColor(red: 0.125490196, green: 0.058823529, blue: 0.192156863, alpha: 1.0))
    .corner(CornerType(60))
    .image()

let image4 = image3?.adjust()
    .hardMix(color: UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0))
    .image()

let image5 = image4?.adjust()
    .append(
        image1!.adjust()
            .outputSize(CGSize(width: 250, height: 250))
            .opacity(0.5)
    )
    .image()

let image6 = image4 + image1

let image7 = image3?.adjust()
    .rotate(15 * CGFloat.pi / 180)
    .image()

let image9 = image5?.adjust()
    .blur(8)
    .image()


