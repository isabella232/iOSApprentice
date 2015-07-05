//
//  ViewController.swift
//  Checklist
//
//  Created by Jay on 15/6/29.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit



class ChecklistViewController: UITableViewController ,ItemDetailViewControllerDelegate{


    var items:[ChecklistItem]
    
    var checklist:Checklist!
  
    func itemDetailViewControllerDidCancel(controller: ItemDetailViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func itemDetailViewController(controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem) {
        
        
        let newRowIndex = items.count
        
        items.append(item)
        
        
        let indexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        
        let indexPaths = [indexPath]
        
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        
        
        dismissViewControllerAnimated(true, completion: nil)
        
        saveChecklistItems()
    }
    
    func itemDetailViewController(controller:ItemDetailViewController,didFinishEditingItem item:ChecklistItem) {
        
        
        if let index = items.indexOf(item){

            let indexPath = NSIndexPath(forRow: index, inSection: 0)
            
            if let cell = tableView.cellForRowAtIndexPath(indexPath){
            
                configureTextForCell(cell, withChecklistItem: item)
            }
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        
        saveChecklistItems()
    }
    
    required init (coder aDecoder:NSCoder){
        
        items = [ChecklistItem]()
        
        super.init(coder: aDecoder)
        
        loadChecklistItems()
        
        //print("Documents folder is : \(documentsDirectory())")
        
        //print("Data File path is：\(dataFilePath())")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 44
        
        title = checklist.name
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        

    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ChecklistItem") as UITableViewCell!
        
        let item = items[indexPath.row]
        
        configureTextForCell(cell, withChecklistItem: item)
        
        configureCheckmarkForCell(cell, withChecklistItem:item)
        
        return cell
    }

    override func tableView(tableView:UITableView,didSelectRowAtIndexPath indexPath:NSIndexPath){
    
        if let cell = tableView.cellForRowAtIndexPath(indexPath){
        
            let item = items[indexPath.row]
            
            item.toggleChecked()
            
            configureCheckmarkForCell(cell,withChecklistItem:item)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        saveChecklistItems()
    }
    
    func configureTextForCell(cell:UITableViewCell,withChecklistItem item:ChecklistItem){
        
        let label = cell.viewWithTag(1000) as! UILabel
        
        label.text = item.text
        
    }
    
    func configureCheckmarkForCell(cell:UITableViewCell,withChecklistItem item:ChecklistItem){
    
        let label = cell.viewWithTag(1001) as! UILabel
        
        if item.checked {
        
            label.text = "√"
            
        } else {
        
            label.text = ""
        }
        
    }
    
    override func tableView(tableView:UITableView,commitEditingStyle editingStyle:UITableViewCellEditingStyle,forRowAtIndexPath indexPath:NSIndexPath){
    
        items.removeAtIndex(indexPath.row)
        
        let indexPaths = [indexPath]
        
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
        
        saveChecklistItems()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "AddItem" {
            
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! ItemDetailViewController
            
            controller.delegate = self
            
        } else if segue.identifier == "EditItem" {
        
            let navigationController = segue.destinationViewController as! UINavigationController
            
            let controller = navigationController.topViewController as! ItemDetailViewController
            
            controller.delegate = self
            
            if let indexPath = tableView.indexPathForCell(sender as! UITableViewCell){
            
                controller.itemToEdit = items[indexPath.row]
                
            }
        }
    }

    
    func documentsDirectory()->String {
    
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        
        return paths[0]
    }
    
    
    func dataFilePath() ->String {
    
        return documentsDirectory().stringByAppendingPathComponent("Checklist.plist")
        
    }
    
    func saveChecklistItems(){
    
        let data = NSMutableData()
    
        let archiver = NSKeyedArchiver(forWritingWithMutableData: data)
        
        archiver.encodeObject(items, forKey: "ChecklistItems")
        
        archiver.finishEncoding()
        
        data.writeToFile(dataFilePath(), atomically: true)
    
    }
    
    func loadChecklistItems(){
        
        let path = dataFilePath()
        
        if NSFileManager.defaultManager().fileExistsAtPath(path){
        
            if let data = NSData(contentsOfFile: path){
            
                let unarchiver = NSKeyedUnarchiver(forReadingWithData: data)
                
                items = unarchiver.decodeObjectForKey("ChecklistItems") as! [ChecklistItem]
                
                unarchiver.finishDecoding()
            }
        }
    }
    
}

