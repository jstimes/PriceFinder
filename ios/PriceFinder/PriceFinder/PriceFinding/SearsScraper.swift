//
//  SearsScraper.swift
//  PriceFinder
//
//  Created by jacob stimes on 8/7/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation

/// Still waiting for Sears response for api key
class SearsScraper : Scraper, ScraperProtocol {
    
    let url = "http://api.developer.sears.com/v2.1/products/search/"; //Sears/json/keyword/{keyword}?apikey=XXXXXXXX";
    
    let apiKeyParam = "apikey";
    
    let queryParam = "keyword";
    
    let responseType = "json";
    
    let apiKey = Config.SearsApiKey;
    
    
    init() {
        super.init(site: "Sears");
    }
    
    func search(keywords: String) -> [Item] {
        var items = [Item]();
        
        items.appendContentsOf(self.searchForSite("Sears"));
        items.appendContentsOf(self.searchForSite("Kmart"));
        
        return items;
    }
    
    func searchForSite(site: String) -> [Item] {
        self.keywords = keywords;
        
        let s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy();
        s.addCharactersInString("+&");
        
        var query = site + "/" + self.responseType + "/";
        
        query = query + queryParam + "/" + self.keywords!.stringByAddingPercentEncodingWithAllowedCharacters(s as! NSCharacterSet)! + "?";
        
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