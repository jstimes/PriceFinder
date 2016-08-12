//
//  SavedItemMO.swift
//  PriceFinder
//
//  Created by jacob stimes on 7/18/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation
import CoreData

class SavedItemMO: NSManagedObject {
    
    
    @NSManaged var title: String?
    
    @NSManaged var vendor: String?
    
    @NSManaged var siteDescription: String?
    
    @NSManaged var price: Double
    
    @NSManaged var link: String?
    
    @NSManaged var groupId: Int16
    
}