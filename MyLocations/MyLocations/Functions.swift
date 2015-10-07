//
//  Functions.swift
//  MyLocations
//
//  Created by Jay on 15/10/7.
//  Copyright © 2015年 look4us. All rights reserved.
//

import Foundation

import Dispatch

func afterDelay(seconds:Double,closure:() ->()) {

    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds*Double(NSEC_PER_SEC)))
    
    dispatch_after(when, dispatch_get_main_queue(), closure)

}