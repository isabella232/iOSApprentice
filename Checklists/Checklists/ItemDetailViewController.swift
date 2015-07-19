//
//  ItemDetailViewController.swift
//  Checklists
//
//  Created by Jay on 15/7/18.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit

protocol ItemDetailViewControllerDelegate: class {


    func itemDetailViewControllerDidCancel(controller:ItemDetailViewController)
    
    func itemDetailViewController(controller: ItemDetailViewController,didFinishAddingItem item:ChecklistItem)
    
    
    func itemDetailViewController(controller:ItemDetailViewController,
    
        didFinishEditingItem item:ChecklistItem)
    
}

class ItemDetailViewController: UITableViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    weak var delegate: ItemDetailViewControllerDelegate?
    
    
    var itemToEdit: ChecklistItem?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.rowHeight = 44
        
        if let item = itemToEdit {
        
            title = "Edit item"
            
            textField.text = item.text
            
            doneBarButton.enabled = true
            
        }
    }
    
    @IBAction func cancel() {
    
        delegate?.itemDetailViewControllerDidCancel(self)
        
    }
    
    @IBAction func done() {
        
        
        if let item = itemToEdit {
        
            item.text = textField.text!
            
            delegate?.itemDetailViewController(self, didFinishEditingItem: item)
        
        
        } else {
        
        let item = ChecklistItem()
        
        item.text = textField.text!
        
        item.checked = false
        
            delegate?.itemDetailViewController(self, didFinishAddingItem: item)
        
        }
    
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        textField.becomeFirstResponder()
        
    }
    
    func textField(textField: UITextField,
    
        shouldChangeCharactersInRange range: NSRange,
    
        repalcementString string: String) -> Bool {
    
    
            let oldText: NSString = textField.text!
            
            let newText: NSString = oldText.stringByReplacingCharactersInRange(range, withString: string)
            
            doneBarButton.enabled = (newText.length > 0)
            
            return true
    }

}
