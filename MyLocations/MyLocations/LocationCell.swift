//
//  LocationCell.swift
//  MyLocations
//
//  Created by Jay on 15/10/7.
//  Copyright © 2015年 look4us. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel:UILabel!
    
    @IBOutlet weak var addressLabel:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureForLocation(location:Location) {
    
        if location.locatoinDescription!.isEmpty {
            
            descriptionLabel.text = "(No Description)"
        
        } else {
        
            
            descriptionLabel.text = location.locatoinDescription
        }
        
        
        //let addressLabel = cell.viewWithTag(101) as! UILabel
        
        if let placemark = location.placemark {
            
            var text = ""
            
            if let s = placemark.subThoroughfare {
                
                text += s + " "
                
            }
            
            if let s = placemark.thoroughfare {
                
                text += s + ", "
                
            }
            
            if let s = placemark.locality{
                
                text += s
                
            }
            
            addressLabel.text = text
            
        } else {
            
            addressLabel.text = String(format: "Lat:%.8f,Long:%.8f", location.latitude,location.longitude)
            
        }
    
    }

}
