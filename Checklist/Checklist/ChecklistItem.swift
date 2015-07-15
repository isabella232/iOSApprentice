//
//  ChecklistItem.swift
//  Checklist
//
//  Created by Jay on 15/7/3.
//  Copyright © 2015年 look4us. All rights reserved.
//

import Foundation

class ChecklistItem:NSObject,NSCoding {
    
    var text = ""
    
    var checked = false
 
    
    var dueDate = NSDate()
    
    var shouldRemind = false
    
    var itemID:Int
    
    
    required init?(coder aDecoder:NSCoder){
        
        text =  aDecoder.decodeObjectForKey("Text") as! String
        
        checked = aDecoder.decodeBoolForKey("Checked")
        
        dueDate = aDecoder.decodeObjectForKey("DueDate") as! NSDate
        
        shouldRemind = aDecoder.decodeBoolForKey("ShouldRemind")
        
        itemID = aDecoder.decodeIntegerForKey("ItemID")
        
        super.init()
    }
    
    
    override init() {
        
        itemID = DataModel.nextChecklistItemID()
        
        super.init()
        
    }
    
    func toggleChecked() {
        
        checked = !checked
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        aCoder.encodeObject(text, forKey: "Text")
        
        aCoder.encodeBool(checked, forKey: "Checked")
        
        aCoder.encodeObject(dueDate,forKey:"DueDate")
        
        aCoder.encodeBool(shouldRemind, forKey: "ShouldRemind")
        
        aCoder.encodeInteger(itemID, forKey: "ItemID")
    }
}