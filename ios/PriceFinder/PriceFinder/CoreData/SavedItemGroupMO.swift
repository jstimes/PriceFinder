//
//  SavedItemGroupMO.swift
//  PriceFinder
//
//  Created by jacob stimes on 7/18/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit
import Foundation
import CoreData

/*
	@brief Database entry representing a user's saved item search.
		Slightly redundant with HomeItem, but the purpose of the 
		redundancy is to abstract the managed object details, and 
		because Item objects may not actually be saved if they are
		discarded search results, so I wanted separate model objects
*/
class SavedItemGroupMO : NSManagedObject {
    
    @NSManaged var searchText: String?
    
    @NSManaged var targetPrice: Double
    
    @NSManaged var groupId: Int16
    
    @NSManaged var dateAdded: NSDate
    
}
