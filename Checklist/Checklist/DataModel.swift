//
//  DataModel.swift
//  Checklist
//
//  Created by Jay on 15/7/6.
//  Copyright © 2015年 look4us. All rights reserved.
//

import Foundation

class DataModel {
    
    var lists = [Checklist]()
    
    init(){
    
        print("Documents folder is : \(documentsDirectory())")
        
        print("Data File path is：\(dataFilePath())")
        
        loadChecklists()
        
        registerDefaults()
        
        handleFirstTime()
    }
    
    func documentsDirectory()->String {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        return paths[0]
    }
    
    func dataFilePath()->String {
        
        return documentsDirectory().stringByAppendingPathComponent("Checklists.plist")
    }
    
    func saveChecklists() {
        
        let data = NSMutableData()
        
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        
        archiver.encodeObject(lists, forKey: "Checklists")
        
        archiver.finishEncoding()
        
        data.writeToFile(dataFilePath(), atomically: true)
    }
    
    func loadChecklists() {
        
        let path = dataFilePath()
        
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            
            if let data = NSData(contentsOfFile: path) {
                
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                
                lists = unarchiver.decodeObjectForKey("Checklists") as! [Checklist]
                
                unarchiver.finishDecoding()
                
                sortChecklists()
            }
            
        }
    }
    
    func registerDefaults(){
    
        let dictionary = ["ChecklistIndex":-1,"FirstTime":true]
        
        NSUserDefaults.standardUserDefaults().registerDefaults(dictionary)
    }
    
    var indexOfSelectedChecklist:Int{
    
        get {
        
            return NSUserDefaults.standardUserDefaults().integerForKey("ChecklistIndex")
        }
        
        set {
        
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "ChecklistIndex")
            
            NSUserDefaults.standardUserDefaults().synchronize()
        
        }
    }
    
    func handleFirstTime() {
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        let firstTime = userDefaults.boolForKey("FirstTime")
        
        if firstTime {
        
            let checklist = Checklist(name: "Checklist")
            
            lists.append(checklist)
            
            indexOfSelectedChecklist = 0
            
            userDefaults.setBool(false, forKey: "FirstTime")
        }
        
    }
    
    func sortChecklists(){
    
        lists.sortInPlace({checklist1,checklist2 in return
        
                checklist1.name.localizedStandardCompare(checklist2.name) ==
                                                        NSComparisonResult.OrderedAscending})
    }
    
}