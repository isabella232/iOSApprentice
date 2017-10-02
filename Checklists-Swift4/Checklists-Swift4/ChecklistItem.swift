//
//  ChecklistItem.swift
//  Checklists-Swift4
//
//  Created by Jay on 2017/10/2.
//  Copyright © 2017年 look4us. All rights reserved.
//

import Foundation

class ChecklistItem: NSObject {
    var text = ""
    var checked = false
    
    func toggleChecked() {
        checked = !checked
    }
}
