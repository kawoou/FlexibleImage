//
//  ViewController.swift
//  Example-app-tvOS
//
//  Created by Kawoou on 2017. 5. 15..
//  Copyright © 2017년 test. All rights reserved.
//

import UIKit

import FlexibleImageTvOS

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var imageMetal: UIImageView!
    @IBOutlet weak var imageOriginal: UIImageView!
    @IBOutlet weak var imageCG: UIImageView!
    
    @IBOutlet weak var sizeMetal: UILabel!
    @IBOutlet weak var sizeOriginal: UILabel!
    @IBOutlet weak var sizeCG: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var performanceButton: UIButton!
    
    @IBAction func resetClicked(_ sender: UIButton) {
        let image = UIImage(named: "macaron.jpg")
        
        self.imageMetal.image = image
        self.imageOriginal.image = image
        self.imageCG.image = image
        
        let metalSize = self.imageMetal.image!.size
        let originalSize = self.imageOriginal.image!.size
        let cgSize = self.imageCG.image!.size
        self.sizeMetal.text = "\(metalSize.width)x\(metalSize.height)"
        self.sizeOriginal.text = "\(originalSize.width)x\(originalSize.height)"
        self.sizeCG.text = "\(cgSize.width)x\(cgSize.height)"
    }
    @IBAction func performanceClicked(_ sender: UIButton) {
        var metalTime = 0.0
        var cgTime = 0.0
        
        let processMetal = self.imageMetal.image!
            .adjust()
        let processCG = self.imageCG.image!
            .adjust(true)
        
        var startTime = Date()
        
        _ = processMetal.normal(color: .gray)
            .multiply(color: .gray)
            .lighten(color: .gray)
            .darken(color: .gray)
            .average(color: .gray)
            .add(color: UIColor.lightGray)
            .subtract(color: UIColor.darkGray)
            .difference(color: UIColor.darkGray)
            .negative(color: .gray)
            .screen(color: .gray)
            .exclusion(color: .gray)
            .overlay(color: .lightGray)
            .softLight(color: .lightGray)
            .hardLight(color: .lightGray)
            .colorDodge(color: .gray)
            .colorBurn(color: .gray)
            .linearDodge(color: .gray)
            .linearBurn(color: .gray)
            .linearLight(color: .lightGray)
            .vividLight(color: .gray)
            .pinLight(color: .lightGray)
            .hardMix(color: .gray)
            .reflect(color: .gray)
            .glow(color: .gray)
            .phoenix(color: .gray)
            .hue(color: .blue)
            .saturation(color: .red)
            .color(color: .red)
            .luminosity(color: .darkGray)
            .greyscale()
            .monochrome()
            .invert()
            .sepia()
            .vibrance()
            .solarize()
            .posterize()
            .blur()
            .brightness()
            .chromaKey(color: .red)
            .swizzling()
            .contrast()
            .gamma(2.2)
            .background(color: .red)
            .image()
        
        var endTime = Date()
        metalTime += endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
        
        startTime = Date()
        
        _ = processCG.normal(color: .gray)
            .multiply(color: .gray)
            .lighten(color: .gray)
            .darken(color: .gray)
            .average(color: .gray)
            .add(color: UIColor.lightGray)
            .subtract(color: UIColor.darkGray)
            .difference(color: UIColor.darkGray)
            .negative(color: .gray)
            .screen(color: .gray)
            .exclusion(color: .gray)
            .overlay(color: .lightGray)
            .softLight(color: .lightGray)
            .hardLight(color: .lightGray)
            .colorDodge(color: .gray)
            .colorBurn(color: .gray)
            .linearDodge(color: .gray)
            .linearBurn(color: .gray)
            .linearLight(color: .lightGray)
            .vividLight(color: .gray)
            .pinLight(color: .lightGray)
            .hardMix(color: .gray)
            .reflect(color: .gray)
            .glow(color: .gray)
            .phoenix(color: .gray)
            .hue(color: .blue)
            .saturation(color: .red)
            .color(color: .red)
            .luminosity(color: .darkGray)
            .greyscale()
            .monochrome()
            .invert()
            .sepia()
            .vibrance()
            .solarize()
            .posterize()
            .blur()
            .brightness()
            .chromaKey(color: .red)
            .swizzling()
            .contrast()
            .gamma(2.2)
            .background(color: .red)
            .image()
        
        endTime = Date()
        
        cgTime += endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
        
        self.sizeMetal.text = "42 Times: \(Int(metalTime * 1000))ms"
        self.sizeCG.text = "42 Times: \(Int(cgTime * 1000))ms"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resetClicked(self.resetButton)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 51
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = self.getText(indexPath.row)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let processMetal = self.imageMetal.image!
            .adjust()
        let processCG = self.imageCG.image!
            .adjust(true)
        
        switch tableView.indexPathForSelectedRow?.row ?? 0 {
        case 0:
            _ = processMetal.normal(color: .gray)
            _ = processCG.normal(color: .gray)
        case 1:
            _ = processMetal.multiply(color: .gray)
            _ = processCG.multiply(color: .gray)
        case 2:
            _ = processMetal.lighten(color: .gray)
            _ = processCG.lighten(color: .gray)
        case 3:
            _ = processMetal.darken(color: .gray)
            _ = processCG.darken(color: .gray)
        case 4:
            _ = processMetal.average(color: .gray)
            _ = processCG.average(color: .gray)
        case 5:
            _ = processMetal.add(color: UIColor.lightGray)
            _ = processCG.add(color: UIColor.lightGray)
        case 6:
            _ = processMetal.subtract(color: UIColor.darkGray)
            _ = processCG.subtract(color: UIColor.darkGray)
        case 7:
            _ = processMetal.difference(color: UIColor.darkGray)
            _ = processCG.difference(color: UIColor.darkGray)
        case 8:
            _ = processMetal.negative(color: .gray)
            _ = processCG.negative(color: .gray)
        case 9:
            _ = processMetal.screen(color: .gray)
            _ = processCG.screen(color: .gray)
        case 10:
            _ = processMetal.exclusion(color: .gray)
            _ = processCG.exclusion(color: .gray)
        case 11:
            _ = processMetal.overlay(color: .lightGray)
            _ = processCG.overlay(color: .lightGray)
        case 12:
            _ = processMetal.softLight(color: .lightGray)
            _ = processCG.softLight(color: .lightGray)
        case 13:
            _ = processMetal.hardLight(color: .lightGray)
            _ = processCG.hardLight(color: .lightGray)
        case 14:
            _ = processMetal.colorDodge(color: .gray)
            _ = processCG.colorDodge(color: .gray)
        case 15:
            _ = processMetal.colorBurn(color: .gray)
            _ = processCG.colorBurn(color: .gray)
        case 16:
            _ = processMetal.linearDodge(color: .gray)
            _ = processCG.linearDodge(color: .gray)
        case 17:
            _ = processMetal.linearBurn(color: .gray)
            _ = processCG.linearBurn(color: .gray)
        case 18:
            _ = processMetal.linearLight(color: .lightGray)
            _ = processCG.linearLight(color: .lightGray)
        case 19:
            _ = processMetal.vividLight(color: .gray)
            _ = processCG.vividLight(color: .gray)
        case 20:
            _ = processMetal.pinLight(color: .lightGray)
            _ = processCG.pinLight(color: .lightGray)
        case 21:
            _ = processMetal.hardMix(color: .gray)
            _ = processCG.hardMix(color: .gray)
        case 22:
            _ = processMetal.reflect(color: .gray)
            _ = processCG.reflect(color: .gray)
        case 23:
            _ = processMetal.glow(color: .gray)
            _ = processCG.glow(color: .gray)
        case 24:
            _ = processMetal.phoenix(color: .gray)
            _ = processCG.phoenix(color: .gray)
        case 25:
            _ = processMetal.hue(color: .blue)
            _ = processCG.hue(color: .blue)
        case 26:
            _ = processMetal.saturation(color: .red)
            _ = processCG.saturation(color: .red)
        case 27:
            _ = processMetal.color(color: .red)
            _ = processCG.color(color: .red)
        case 28:
            _ = processMetal.luminosity(color: .darkGray)
            _ = processCG.luminosity(color: .darkGray)
        case 29:
            _ = processMetal.greyscale()
            _ = processCG.greyscale()
        case 30:
            _ = processMetal.monochrome()
            _ = processCG.monochrome()
        case 31:
            _ = processMetal.invert()
            _ = processCG.invert()
        case 32:
            _ = processMetal.sepia()
            _ = processCG.sepia()
        case 33:
            _ = processMetal.vibrance()
            _ = processCG.vibrance()
        case 34:
            _ = processMetal.solarize()
            _ = processCG.solarize()
        case 35:
            _ = processMetal.posterize()
            _ = processCG.posterize()
        case 36:
            _ = processMetal.blur()
            _ = processCG.blur()
        case 37:
            _ = processMetal.brightness()
            _ = processCG.brightness()
        case 38:
            _ = processMetal.chromaKey(color: .red)
            _ = processCG.chromaKey(color: .red)
        case 39:
            _ = processMetal.swizzling()
            _ = processCG.swizzling()
        case 40:
            _ = processMetal.contrast()
            _ = processCG.contrast()
        case 41:
            _ = processMetal.gamma(2.2)
            _ = processCG.gamma(2.2)
        case 42:
            _ = processMetal.background(color: .red)
            _ = processCG.background(color: .red)
        case 43:
            _ = processMetal.scaling(CGSize(width: 0.25, height: 0.25))
            _ = processCG.scaling(CGSize(width: 0.25, height: 0.25))
        case 44:
            _ = processMetal.offset(CGPoint(x: 25, y: 25))
            _ = processCG.offset(CGPoint(x: 25, y: 25))
        case 45:
            _ = processMetal.opacity(0.5)
            _ = processCG.opacity(0.5)
        case 46:
            _ = processMetal.rotate(CGFloat.pi * 0.25)
            _ = processCG.rotate(CGFloat.pi * 0.25)
        case 47:
            _ = processMetal.margin(EdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
            _ = processCG.margin(EdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        case 48:
            _ = processMetal.padding(EdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
            _ = processCG.padding(EdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        case 49:
            _ = processMetal.border(color: .red, lineWidth: 4, radius: 4)
            _ = processCG.border(color: .red, lineWidth: 4, radius: 4)
        case 50:
            _ = processMetal.corner(CornerType(15))
            _ = processCG.corner(CornerType(15))
        default:
            break
        }
        
        self.imageMetal.image = processMetal.image()
        self.imageCG.image = processCG.image()
        
        let metalSize = self.imageMetal.image!.size
        let cgSize = self.imageCG.image!.size
        self.sizeMetal.text = "\(metalSize.width)x\(metalSize.height)"
        self.sizeCG.text = "\(cgSize.width)x\(cgSize.height)"
    }
    
    func getText(_ row: Int) -> String {
        switch row {
        case 0:
            return "normal"
        case 1:
            return "multiply"
        case 2:
            return "lighten"
        case 3:
            return "darken"
        case 4:
            return "average"
        case 5:
            return "add"
        case 6:
            return "subtract"
        case 7:
            return "difference"
        case 8:
            return "negative"
        case 9:
            return "screen"
        case 10:
            return "exclusion"
        case 11:
            return "overlay"
        case 12:
            return "softLight"
        case 13:
            return "hardLight"
        case 14:
            return "colorDodge"
        case 15:
            return "colorBurn"
        case 16:
            return "linearDodge"
        case 17:
            return "linearBurn"
        case 18:
            return "linearLight"
        case 19:
            return "vividLight"
        case 20:
            return "pinLight"
        case 21:
            return "hardMix"
        case 22:
            return "reflect"
        case 23:
            return "glow"
        case 24:
            return "phoenix"
        case 25:
            return "hue"
        case 26:
            return "saturation"
        case 27:
            return "color"
        case 28:
            return "luminosity"
        case 29:
            return "greyscale"
        case 30:
            return "monochrome"
        case 31:
            return "invert"
        case 32:
            return "sepia"
        case 33:
            return "vibrance"
        case 34:
            return "solarize"
        case 35:
            return "posterize"
        case 36:
            return "blur"
        case 37:
            return "brightness"
        case 38:
            return "chromaKey"
        case 39:
            return "swizzling"
        case 40:
            return "contrast"
        case 41:
            return "gamma"
        case 42:
            return "background"
        case 43:
            return "scaling"
        case 44:
            return "offset"
        case 45:
            return "opacity"
        case 46:
            return "rotate"
        case 47:
            return "margin"
        case 48:
            return "padding"
        case 49:
            return "border"
        case 50:
            return "corner"
        default:
            return ""
        }
    }

}

