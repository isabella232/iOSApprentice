//
//  ChecklistItem.swift
//  Checklist
//
//  Created by Jay on 15/7/3.
//  Copyright © 2015年 look4us. All rights reserved.
//

import Foundation
import UIKit

class ChecklistItem:NSObject,NSCoding {
    
    var text = ""
    
    var checked = false
 
    
    var dueDate = NSDate()
    
    var shouldRemind = false
    
    var itemID:Int
    
    override init() {
        
        itemID = DataModel.nextChecklistItemID()
        
        super.init()
        
    }
    
    required init?(coder aDecoder:NSCoder){
        
        text =  aDecoder.decodeObjectForKey("Text") as! String
        
        checked = aDecoder.decodeBoolForKey("Checked")
        
        dueDate = aDecoder.decodeObjectForKey("DueDate") as! NSDate
        
        shouldRemind = aDecoder.decodeBoolForKey("ShouldRemind")
        
        itemID = aDecoder.decodeIntegerForKey("ItemID")
        
        super.init()
    }
    
    deinit {
        
        let existingNotification = notificationForThisItem()
        
        if let notification = existingNotification {
        
            print("Removing existing notification \(notification)")
            
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
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
    
    func scheduleNotification() {
        
        let existingNotification = notificationForThisItem()
        
        if let notification = existingNotification {
        
            print("Found an existing notification \(notification)")
            
            UIApplication.sharedApplication().cancelLocalNotification(notification)
        }
        
        
        if shouldRemind && dueDate.compare(NSDate()) != NSComparisonResult.OrderedAscending {
        
            let localNotification = UILocalNotification()
            
            localNotification.fireDate = dueDate
            
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            
            localNotification.alertBody = text
            
            localNotification.soundName = UILocalNotificationDefaultSoundName
            
            localNotification.userInfo = ["ItemID":itemID]
            
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            
            print("Scheduled notification\(localNotification) for itemID \(itemID)!")
            
        }
    }
    
    func notificationForThisItem()->UILocalNotification? {
    
        let allNotification = UIApplication.sharedApplication().scheduledLocalNotifications as[UILocalNotification]!
        
        for notification in allNotification {
            
            if let number = notification.userInfo?["ItemID"] as? NSNumber {
            
                if number.integerValue == itemID {
                    
                    return notification
                
                }
            }
        }
    
        return nil
    
    }
}