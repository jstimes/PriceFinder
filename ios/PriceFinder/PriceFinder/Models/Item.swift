//
//  Item.swift
//  PriceFinder
//
//  Created by jacob stimes on 5/22/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.

///Model for an individual item from a site. Used for search results, and the items within a user's saved search (HomeItem)
class Item  {
    
    var title: String?
    
    var vendor: String?
    
    var price: Double
    
    var link: String?
    
    var thumbnailLink: String?
    
    
    init(title: String, price: Double, vendor: String, link: String, thumbnailLink: String = "") {
        
        self.title = title;
        self.price = price;
        self.vendor = vendor;
        self.link = link;
        self.thumbnailLink = thumbnailLink;
    }
}
