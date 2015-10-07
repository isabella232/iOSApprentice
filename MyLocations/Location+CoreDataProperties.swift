//
//  Location+CoreDataProperties.swift
//  MyLocations
//
//  Created by Jay on 15/10/7.
//  Copyright © 2015年 look4us. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreLocation


extension Location {

    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var placemark: CLPlacemark?
    @NSManaged var locatoinDescription: String?
    @NSManaged var date: NSDate
    @NSManaged var category: String?

}
