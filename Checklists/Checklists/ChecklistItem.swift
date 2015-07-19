//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Jay on 15/7/18.
//  Copyright © 2015年 look4us. All rights reserved.
//

import Foundation

class ChecklistItem:NSObject,NSCoding {


    var text = ""
    
    var checked = false
    
    required init(coder aDecoder: NSCoder) {
    
        text = aDecoder.decodeObjectForKey("Text") as! String
        
        checked = aDecoder.decodeBoolForKey("Checked")
        
        super.init()
        
    }
    
    override init() {
        
        super.init()
        
    }
    
    func toggleChecked(){
    
        checked = !checked
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(text, forKey: "Text")
        
        aCoder.encodeObject(checked, forKey: "Checked")
    }
}
