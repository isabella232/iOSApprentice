//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Jay on 15/12/8.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit

extension UIImageView {

    func loadImageWithURL(url:NSURL) -> NSURLSessionDownloadTask {
    
        let session = NSURLSession.sharedSession()
        
        let downloadTask = session.downloadTaskWithURL(url,completionHandler: {
            
            [weak self] url,response,error in
            
            if error == nil ,let url = url, data = NSData(contentsOfURL: url),image = UIImage(data: data) {
            
                dispatch_async(dispatch_get_main_queue()){
                
                    if let strongSelf = self {
                    
                        strongSelf.image = image
                    
                    }
                }
            }
        })
        
        downloadTask.resume()
        
        return downloadTask
    }

}
