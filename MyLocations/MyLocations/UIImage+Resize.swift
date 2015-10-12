//
//  UIImage+Resize.swift
//  MyLocations
//
//  Created by Jay on 15/10/11.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit

extension UIImage {

    func resizedImageWithBounds(bounds:CGSize) -> UIImage {
    
        let horizontalRatio = bounds.width / size.width
        
        let verticalRatio = bounds.height / size.height
        
        let ratio = min(horizontalRatio, verticalRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        
        drawInRect(CGRect(origin: CGPoint.zero, size: newSize))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return newImage
    
    }

}
