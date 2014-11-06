//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Jay on 14/11/6.
//  Copyright (c) 2014年 Jay. All rights reserved.
//

import Foundation

class ChecklistItem {
    var text = ""
    var checked = false
    
    func toggleChecked() {
        checked = !checked
    }
}