//
//  HomeItem.swift
//  PriceFinder
//
//  Created by jacob stimes on 6/7/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation

/*!
	@brief Represents a user's saved product search. Not a single item, but can contain multiple items related to title - the user's search query.
	I didn't want to use the managed object counterpart to avoid unintentional database updates
*/
class HomeItem {
    
    var groupId: Int16?
    
    var title: String!
    
    var targetPrice: Double!
    
    var lowestPrice: Double!
    
    var items: [Item] = []
    
    var dateAdded: NSDate?
    
    init(groupId: Int16, title:String, targetPrice price:Double, dateAdded: NSDate, withItems items:[Item]){
        self.groupId = groupId;
        self.title = title;
        self.targetPrice = price;
        self.dateAdded = dateAdded;
        self.sortAndAddItems(items);
    }
    
    init(title:String, targetPrice price:Double, withItems items:[Item]){
        self.title = title;
        self.targetPrice = price;
        self.sortAndAddItems(items);
    }
    
    private func sortAndAddItems(items: [Item]) {
        //Sort so that those with the largest value of (targetPrice - lowestPrice) are at top:
        // i.e. the biggest deals show up at top:
        self.items.appendContentsOf(items.sort( { (first: Item, second: Item ) -> Bool in
            let firstDiff = self.targetPrice - first.price;
            let secondDiff = self.targetPrice - second.price;
            
            return firstDiff > secondDiff;
        }));
        
        self.lowestPrice = self.items.first!.price;
    }
}
