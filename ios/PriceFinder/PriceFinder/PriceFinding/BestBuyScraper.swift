//
//  BestBuyScraper.swift
//  PriceFinder
//
//  Created by jacob stimes on 7/25/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation

/// Queries the Best buy api
class BestBuyScraper : Scraper, ScraperProtocol {
    
    let apiKey = Config.BestBuyApiKey;
    let url = "https://api.bestbuy.com/v1/products";
    let apiKeyParam = "apiKey";
    
    init() {
        super.init(site:"Best Buy");
    }
    
    func search(keywords: String) -> [Item] {
        self.keywords = keywords;
        
        let s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy()
        s.addCharactersInString("+&")
        var query = "(" + getSearchText().stringByAddingPercentEncodingWithAllowedCharacters(s as! NSCharacterSet)! + ")?";
        
        query = query + apiKeyParam + "=" + apiKey.stringByAddingPercentEncodingForRFC3986()!;
        query = query + "&format=json"
        query = query + "&show=thumbnailImage,mobileUrl,name,onSale,regularPrice,salePrice,shortDescription&pageSize=20".stringByAddingPercentEncodingWithAllowedCharacters(s as! NSCharacterSet)!;
        
        let queryUrl = url + query;
        
        let json = self.parseIntoJSON(self.getJSON(queryUrl));
        return getItemsFromJSON(json);
    }
    
    func getItemsFromJSON(results: JSON) -> [Item] {
        var items = [Item]();
        
        let itemsNode = "products";
        
        let itemsJsonArray = results[itemsNode] as! [JSON];
        for itemJson in itemsJsonArray {
            let name = itemJson["name"] as! String;
            let salePrice = itemJson["salePrice"] as! NSNumber;
            let link = itemJson["mobileUrl"] as! String;
            
            var thumbnailLink = "";
            if let tryLink = itemJson["thumbnailImage"] as? String {
                thumbnailLink = tryLink;
            }
            
            items.append(Item(title: name, price: Double(salePrice), vendor: site, link: link, thumbnailLink: thumbnailLink));
        }
        
        return items;
    }
    
    private func getSearchText() -> String {
        var toReturn = "";
        var amp = false;
        
        for keyword in self.keywords!.componentsSeparatedByString(" ") {
            if amp {
                toReturn += "&";
            }
            toReturn += "search=" + keyword;
            
            amp = true;
        }
        
        return toReturn;
    }
}