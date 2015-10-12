//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Jay on 15/10/11.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return .LightContent
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        
        return nil
    }
    
}
