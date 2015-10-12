//
//  String+AddText.swift
//  MyLocations
//
//  Created by Jay on 15/10/11.
//  Copyright © 2015年 look4us. All rights reserved.
//

extension String{

    mutating func addText(text: String?, withSeparator separator: String = "") {
    
        if let text = text {
        
            if !isEmpty {
            
                self += separator
            }
        
            self += text
        }
    }
}