//
//  EbayScraper.swift
//  PriceFinder
//
//  Created by jacob stimes on 8/7/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation

///Searches ebay API, which is one of the most frustrating API's I've worked with
class EbayScraper : Scraper, ScraperProtocol {
    
    let url = "http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByKeywords&SERVICE-VERSION=1.0.0";
    //&SECURITY-APPNAME=YourAppID
    //&RESPONSE-DATA-FORMAT=XML
    //&REST-PAYLOAD
    //&keywords=harry%20potter%20phoenix";
    
    let apiKeyParam = "SECURITY-APPNAME";
    
    let apiKey = Config.EbayApiKey;
    
    let responseTypeParam = "RESPONSE-DATA-FORMAT";
    
    let responseType = "JSON";
    
    let payloadParam = "REST-PAYLOAD";
    
    let keywordParam = "keywords";
    
    
    init() {
        super.init(site:"eBay");
    }
    
    func search(keywords: String) -> [Item] {
        self.keywords = keywords;
        
        let s = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy()
        s.addCharactersInString("+&")
        var query = "&" + (self.apiKeyParam + "=" + self.apiKey).stringByAddingPercentEncodingWithAllowedCharacters(s as! NSCharacterSet)!;
        
        query += "&" + responseTypeParam + "=" + responseType;
        
        query += "&" + self.payloadParam;
        
        query += "&" + keywordParam + "=" + self.keywords!.stringByAddingPercentEncodingWithAllowedCharacters(s as! NSCharacterSet)!;
        
        let queryUrl = url + query;
        
        let json = self.parseIntoJSON(self.getJSON(queryUrl));
        return getItemsFromJSON(json);
    }
    
    //Ebay has a pretty stupid json response type where every single value and object is an array...fun
    func getItemsFromJSON(results: JSON) -> [Item] {
        var items = [Item]();
        
        let mainObj = results["findItemsByKeywordsResponse"] as! [JSON];
        
        let itemsNode = "searchResult";
        
        var itemsJsonArray: [JSON] = [JSON]();
        
        for entry in mainObj {
            if let searchResults = entry[itemsNode] as? [JSON] {
                itemsJsonArray = searchResults;
                break;
            }
        }

        var itemsJson = [JSON]();
        
        for var itemsTryJson in itemsJsonArray {
            
            if let itemTry = itemsTryJson["item"] as? [JSON] {
                itemsJson = itemTry;
                break;
            }
        }
        
        for itemJson in itemsJson {
        
            let name = (itemJson["title"] as! [String]).first!;
            let link = (itemJson["viewItemURL"] as! [String]).first!;
            
            let listingObj = (itemJson["listingInfo"] as! [JSON]).first! ;
            
            var buyItNowAvailable = false;
            
            if let avail = listingObj["buyItNowAvailable"] as? [AnyObject] {
                let str = avail.first! as! String; //only works as a string, not bool...
                if str == "true" {
                    buyItNowAvailable = true;
                }
                else {
                    NSLog("not available");
                }
            }
            
            if !buyItNowAvailable {
                continue;
            }
            
            let salePriceObj = (listingObj["buyItNowPrice"] as! [JSON]).first!
            let salePrice = NSNumberFormatter().numberFromString((salePriceObj["__value__"] as! String))!.doubleValue;
            
            //let thumbnailLink = itemJson["thumbnailImage"] as! String;
            
            items.append(Item(title: name, price: salePrice, vendor: site, link: link));
        }
        
        return items;
    }
}
