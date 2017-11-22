//
//  ViewController.swift
//  ColorFlow
//
//  Created by Adam Wienconek on 17.07.2017.
//  Copyright © 2017 Adam Wienconek. All rights reserved.
//

import UIKit

public struct UIImageColors{
    var backgroundColor: UIColor!
    var primaryColor: UIColor!
    var secondaryColor: UIColor!
    var detailColor: UIColor!
}

class PCCountedColor{
    let color: UIColor
    let count: Int
    
    init(color: UIColor, count: Int){
        self.color = color
        self.count = count
    }
}

extension UIScrollView {
    var currentPage:Int{
        return Int((self.contentOffset.x+(0.5*self.frame.size.width))/self.frame.width)+1
    }
}

extension CGColor{
    var components: [CGFloat]{
        get{
            var red = CGFloat()
            var green = CGFloat()
            var blue = CGFloat()
            var alpha = CGFloat()
            UIColor(cgColor: self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return [red, green, blue, alpha]
        }
    }
}

extension UIColor{
    var isDarkColor: Bool{
        let RGB = self.cgColor.components
        return (0.2126 * RGB[0] + 0.7152 * RGB[1] + 0.0722 * RGB[2]) < 0.5
    }
    
    var isBlackOrWhite: Bool{
        let RGB = self.cgColor.components
        return (RGB[0] > 0.01 && RGB[1] > 0.91 && RGB[2] > 0.91) || (RGB[0] < 0.09 && RGB[1] < 0.09 && RGB[2] < 0.09)
    }
    
    func isDistinct(compareColor: UIColor) -> Bool{
        let bg = self.cgColor.components
        let fg = compareColor.cgColor.components
        let threshold: CGFloat = 0.25
        
        if fabs(bg[0] - fg[0]) > threshold || fabs(bg[1] - fg[1]) > threshold || fabs(bg[2] - fg[2]) > threshold{
            if fabs(bg[0] - bg[1]) < 0.03 && fabs(bg[0] - bg[2]) < 0.03{
                if fabs(fg[0] - fg[1]) < 0.03 && fabs(fg[0] - fg[2]) < 0.03{
                    return false
                }
            }
            return true
        }
        return false
    }
    
    func colorWithMinimumSaturation(minSaturation: CGFloat) -> UIColor{
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        if saturation < minSaturation{
            return UIColor(hue: hue, saturation: minSaturation, brightness: brightness, alpha: alpha)
        }else{
            return self
        }
    }
    
    func isContrastingColor(compareColor: UIColor) -> Bool{
        let bg = self.cgColor.components
        let fg = compareColor.cgColor.components
        let bgLum = 0.2126 * bg[0] + 0.7152 * bg[1] + 0.0722 * bg[2]
        let fgLum = 0.2126 * fg[0] + 0.7152 * fg[1] + 0.07211 * fg[2]
        let bgGreater = bgLum > fgLum
        let nom = bgGreater ? bgLum : fgLum
        let denom = bgGreater ? fgLum : bgLum
        let contrast = (nom + 0.05) / (denom + 0.05)
        return 1.6 < contrast
    }
}

extension UIImage{
    private func resizeForUIImageColors(newSize: CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        defer{
            UIGraphicsEndImageContext()
        }
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else{
            fatalError("UIImageColors.resizeForUIImageColors failed: UIGraphicsGetImageFromCurrentImageContext returned nil")
        }
        return result
    }
    
    public func getColors(scaleDownSize: CGSize = CGSize.zero, completionHandler: @escaping (UIImageColors) -> Void) {
        DispatchQueue.global().async {
            let result = self.getColors(scaleDownSize: scaleDownSize)
            
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
    }
    
    public func getColors(scaleDownSize: CGSize = CGSize.zero) -> UIImageColors{
        var scaleDownSize = scaleDownSize
        if scaleDownSize == CGSize.zero{
            let ratio = self.size.width/self.size.height
            let r_width: CGFloat = 250
            scaleDownSize = CGSize(width: r_width, height: r_width/ratio)
        }
        var result = UIImageColors()
        let cgImage = self.resizeForUIImageColors(newSize: scaleDownSize).cgImage!
        let width: Int = cgImage.width
        let height: Int = cgImage.height
        let blackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        let whiteColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        let randomColorsThreshold = Int(CGFloat(height)*0.01)
        let sortedColorComparator: Comparator = { (main, other) -> ComparisonResult in
            let m = main as! PCCountedColor, o = other as! PCCountedColor
            if m.count < o.count{
                return ComparisonResult.orderedDescending
            }else if m.count == o.count{
                return ComparisonResult.orderedSame
            }else{
                return ComparisonResult.orderedAscending
            }
        }
        guard let data = CFDataGetBytePtr(cgImage.dataProvider!.data) else{
            fatalError("Kurwa")
        }
        //Filtrowanie i kolekcja pikseli z obrazka
        let imageColors = NSCountedSet(capacity: width * height)
        
        for x in 0..<width{
            for y in 0..<height{
                let pixel: Int = ((width * y) + x) * 4
                if 127 <= data[pixel+3]{
                    imageColors.add(UIColor(red: CGFloat(data[pixel+2])/255, green: CGFloat(data[pixel+1])/255, blue: CGFloat(data[pixel])/255, alpha: 1.0))
                }
            }
        }
        //Ustawienie koloru tla
        var enumerator = imageColors.objectEnumerator()
        var sortedColors = NSMutableArray(capacity: imageColors.count)
        while let kolor = enumerator.nextObject() as? UIColor{
            let colorCount = imageColors.count(for: kolor)
            if randomColorsThreshold < colorCount{
                sortedColors.add(PCCountedColor(color: kolor, count: colorCount))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)
        var proposedEdgeColor: PCCountedColor
        if 0 < sortedColors.count{
            proposedEdgeColor = sortedColors.object(at: 0) as! PCCountedColor
        }else{
            proposedEdgeColor = PCCountedColor(color: blackColor, count: 1)
        }
        
        if proposedEdgeColor.color.isBlackOrWhite && 0 < sortedColors.count{
            for i in 1..<sortedColors.count{
                let nextProposedEdgeColor = sortedColors.object(at: i) as! PCCountedColor
                if (CGFloat(nextProposedEdgeColor.count)/CGFloat(proposedEdgeColor.count)) > 0.3{
                    if !nextProposedEdgeColor.color.isBlackOrWhite{
                        proposedEdgeColor = nextProposedEdgeColor
                        break
                    }
                }else{
                    break
                }
            }
        }
        result.backgroundColor = proposedEdgeColor.color
        
        //Kolory na pierwszym planie
        enumerator = imageColors.objectEnumerator()
        sortedColors.removeAllObjects()
        sortedColors = NSMutableArray(capacity: imageColors.count)
        let findDarkTextColor = !result.backgroundColor.isDarkColor
        
        while var kolor = enumerator.nextObject() as? UIColor{
            kolor = kolor.colorWithMinimumSaturation(minSaturation: 0.15)
            if kolor.isDarkColor == findDarkTextColor{
                let colorCount = imageColors.count(for: kolor)
                sortedColors.add(PCCountedColor(color: kolor, count: colorCount))
            }
        }
        sortedColors.sort(comparator: sortedColorComparator)
        
        for curContainer in sortedColors{
            let kolor = (curContainer as! PCCountedColor).color
            
            if result.primaryColor == nil{
                if kolor.isContrastingColor(compareColor: result.backgroundColor){
                    result.primaryColor = kolor
                }
            }else if result.secondaryColor == nil{
                if !result.primaryColor.isDistinct(compareColor: kolor) || !result.primaryColor.isDistinct(compareColor: kolor) || !kolor.isContrastingColor(compareColor: result.backgroundColor){
                    continue
                }
                result.detailColor = kolor
                break
            }
        }
        
        let isDarkBackground = result.backgroundColor.isDarkColor
        if result.primaryColor == nil{
            result.primaryColor = isDarkBackground ? whiteColor:blackColor
        }
        if result.secondaryColor  == nil{
            result.secondaryColor = isDarkBackground ? whiteColor:blackColor
        }
        if result.detailColor == nil{
            result.detailColor = isDarkBackground ? whiteColor:blackColor
        }
        return result
    }
}

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let coreImageColor = self.coreImageColor
        return (coreImageColor.red, coreImageColor.green, coreImageColor.blue, coreImageColor.alpha)
    }
}

public extension UIImage {
    
    /// Tint, Colorize image with given tint color
    /// This is similar to Photoshop's "Color" layer blend mode
    /// This is perfect for non-greyscale source images, and images that
    /// have both highlights and shadows that should be preserved<br><br>
    /// white will stay white and black will stay black as the lightness of
    /// the image is preserved
    ///
    /// - Parameter TintColor: Tint color
    /// - Returns:  Tinted image
    public func tintImage(with fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw black background - workaround to preserve color of partially transparent pixels
            context.setBlendMode(.normal)
            UIColor.black.setFill()
            context.fill(rect)
            
            // draw original image
            context.setBlendMode(.normal)
            context.draw(cgImage!, in: rect)
            
            // tint image (loosing alpha) - the luminosity of the original image is preserved
            context.setBlendMode(.color)
            fillColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(context.makeImage()!, in: rect)
        }
    }
    
    /// Tint pictogram with color
    /// Method work on single colors without fading, mainly for svg images
    ///
    /// - Parameter fillColor: TintColor: Tint color
    /// - Returns:             Tinted image
    public func tintPictogram(with fillColor: UIColor) -> UIImage {
        
        return modifiedImage { context, rect in
            // draw tint color
            context.setBlendMode(.normal)
            fillColor.setFill()
            context.fill(rect)
            
            // mask by alpha values of original image
            context.setBlendMode(.destinationIn)
            context.draw(cgImage!, in: rect)
        }
    }
    
    /// Modified Image Context, apply modification on image
    ///
    /// - Parameter draw: (CGContext, CGRect) -> ())
    /// - Returns:        UIImage
    fileprivate func modifiedImage(_ draw: (CGContext, CGRect) -> ()) -> UIImage {
        
        // using scale correctly preserves retina images
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let context: CGContext! = UIGraphicsGetCurrentContext()
        assert(context != nil)
        
        // correctly rotate image
        context.translateBy(x: 0, y: size.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        
        draw(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


