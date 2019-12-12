//
//  ZImageCropper.swift
//  ZImageCropper
//
//  Created by zaid.pathan on 20/02/17.
//  Copyright © 2017 Zaid Pathan. All rights reserved.
//

import Foundation
import UIKit

public class ZImageCropper {
  
  
  
    
    
    public class func cropImage(ofImage:UIImage, withinPoints points:[CGPoint]) -> UIImage? {
        var ofImageView = UIImageView(image: ofImage)
      
      
        //Check if there is start and end points exists
        if points.count >= 2 {
            let path = UIBezierPath()
            let shapeLayer = CAShapeLayer()
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 2
            var croppedImage:UIImage?
            let startX = points[0].x
            let startY = points[6].y
            let startwidth = points[4].x - points[0].x
            let startheight = points[2].y - points[6].y
            for (index,point) in points.enumerated() {
                
                //Origin
                if index == 0 {
                    path.move(to: point)
                    
                //Endpoint
                } else if index == points.count-1 {
                    path.addLine(to: point)
                    path.close()
                    shapeLayer.path = path.cgPath
                    
                    ofImageView.layer.addSublayer(shapeLayer)
                    shapeLayer.fillColor = UIColor.black.cgColor
                    ofImageView.layer.mask = shapeLayer
                    UIGraphicsBeginImageContextWithOptions(ofImageView.frame.size, false, 1)
                    
                    if let currentContext = UIGraphicsGetCurrentContext() {
                        ofImageView.layer.render(in: currentContext)
                    }
                    
                    let newImage = UIGraphicsGetImageFromCurrentImageContext()

                    UIGraphicsEndImageContext()
                    
                    croppedImage = newImage
                  
                  
                     croppedImage = croppedImage?.croppedInRect(rect: CGRect(x: startX, y: startY, width: startwidth, height: startheight))
                  
                    //Move points
                } else {
                    path.addLine(to: point)
                }
            }
            
            return croppedImage
        } else {
            return nil
        }
    }
}






extension UIImage {
  func crop(to:CGSize) -> UIImage {
    guard let cgimage = self.cgImage else { return self }
    
    let contextImage: UIImage = UIImage(cgImage: cgimage)
    
    let contextSize: CGSize = contextImage.size
    
    //Set to square
    var posX: CGFloat = 0.0
    var posY: CGFloat = 0.0
    let cropAspect: CGFloat = to.width / to.height
    
    var cropWidth: CGFloat = to.width
    var cropHeight: CGFloat = to.height
    
    if to.width > to.height { //Landscape
      cropWidth = contextSize.width
      cropHeight = contextSize.width / cropAspect
      posY = (contextSize.height - cropHeight) / 2
    } else if to.width < to.height { //Portrait
      cropHeight = contextSize.height
      cropWidth = contextSize.height * cropAspect
      posX = (contextSize.width - cropWidth) / 2
    } else { //Square
      if contextSize.width >= contextSize.height { //Square on landscape (or square)
        cropHeight = contextSize.height
        cropWidth = contextSize.height * cropAspect
        posX = (contextSize.width - cropWidth) / 2
      }else{ //Square on portrait
        cropWidth = contextSize.width
        cropHeight = contextSize.width / cropAspect
        posY = (contextSize.height - cropHeight) / 2
      }
    }
    
    let rect: CGRect = CGRect(x : posX, y : posY, width : cropWidth, height : cropHeight)
    
    // Create bitmap image from context using the rect
    let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
    
    // Create a new image based on the imageRef and rotate back to the original orientation
    let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
    
    cropped.draw(in: CGRect(x : 0, y : 0, width : to.width, height : to.height))
    
    return cropped
  }
}

extension UIImage {
  func croppedInRect(rect: CGRect) -> UIImage {
    func rad(_ degree: Double) -> CGFloat {
      return CGFloat(degree / 180.0 * .pi)
    }
    
    var rectTransform: CGAffineTransform
    switch imageOrientation {
    case .left:
      rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -self.size.height)
    case .right:
      rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -self.size.width, y: 0)
    case .down:
      rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -self.size.width, y: -self.size.height)
    default:
      rectTransform = .identity
    }
    rectTransform = rectTransform.scaledBy(x: self.scale, y: self.scale)
    
    let imageRef = self.cgImage!.cropping(to: rect.applying(rectTransform))
    let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
    return result
  }
}
