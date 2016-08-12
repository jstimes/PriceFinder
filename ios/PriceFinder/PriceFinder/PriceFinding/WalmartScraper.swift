//
//  WalmartScraper.swift
//  PriceFinder
//
//  Created by jacob stimes on 8/6/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation

/// Queries Walmart API
class WalmartScraper : Scraper, ScraperProtocol {
    
    let url = "http://api.walmartlabs.com/v1/search?";
    
    let apiKeyParam = "apiKey";
    
    let queryParam = "query";
    
    let apiKey = Config.WalmartApiKey;
    
    
    init() {
        super.init(site: "Walmart");
    }
    
    func search(keywords: String) -> [Item] {
        self.keywords = keywords;
        
        let s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy();
        s.addCharactersInString("+&");
        var query = queryParam + "=" + self.keywords!.stringByAddingPercentEncodingWithAllowedCharacters(s as! NSCharacterSet)! + "&";
        
        query = query + apiKeyParam + "=" + apiKey.stringByAddingPercentEncodingForRFC3986()!;
        
        let queryUrl = self.url + query;
        
        let json = self.parseIntoJSON(self.getJSON(queryUrl));
        return getItemsFromJSON(json);
    }
    
    func getItemsFromJSON(results: JSON) -> [Item] {
        var items = [Item]();
        
        let itemsNode = "items";
        
        let itemsJsonArray = results[itemsNode] as! [JSON]
        for itemJson in itemsJsonArray {
            let name = itemJson["name"] as! String;
            let salePrice = itemJson["salePrice"] as! NSNumber;
            let link = itemJson["productUrl"] as! String;
            
            let thumbnailLink = itemJson["thumbnailImage"] as! String;
            
            items.append(Item(title: name, price: Double(salePrice), vendor: site, link: link, thumbnailLink: thumbnailLink));
            
        }
        
        return items;
    }
    
}