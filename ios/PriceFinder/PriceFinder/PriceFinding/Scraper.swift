//
//  Scraper.swift
//  PriceFinder
//
//  Created by jacob stimes on 7/18/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation


typealias JSON = [String : AnyObject];

/// Serves as a base class for JSON API service consumers. Not actually a web scraper
class Scraper {
    
    var site: String;
    var keywords: String?;
    
    var charset = "UTF-8";
    
    init(site: String){
        self.site = site;
    }
    
    /// Given a string url, this method retrieves the data from the page
    func getJSON(urlToRequest: String) -> NSData{
        let url = NSURL(string: urlToRequest);
        //NSLog(urlToRequest)
        let data = NSData(contentsOfURL: url!);
        return data!
    }
    
    /// Given a url's data, this method serializes the data into JSON
    func parseIntoJSON(inputData: NSData) -> JSON {
        do {
            return try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as! JSON
        }
        catch {
            NSLog("Threw an exception parsing NSData into JSON " + site);
            return JSON()
        }
    }
}

/// Contains some methods that Scraper subclasses must implement individually
protocol ScraperProtocol {
    
    /// Given a JSON response object from the url request, this method is responsible for converting it into an Item's array, based on the specific API's response structure
    func getItemsFromJSON(results: JSON) -> [Item];
    
    /// This method should be implemented to form and encode the url request as specified by the specific API, and return the processed results of the request
    func search(keywords: String) -> [Item];
}

/// Provides some encoding utility functions:
extension String {
    public func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString(unreserved)
        return stringByAddingPercentEncodingWithAllowedCharacters(allowed)
    }
    
    public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String? {
        let unreserved = "*-._"
        let allowed = NSMutableCharacterSet.alphanumericCharacterSet()
        allowed.addCharactersInString(unreserved)
        
        if plusForSpace {
            allowed.addCharactersInString(" ")
        }
        
        var encoded = stringByAddingPercentEncodingWithAllowedCharacters(allowed)
        if plusForSpace {
            encoded = encoded?.stringByReplacingOccurrencesOfString(" ",
                                                                    withString: "+")
        }
        return encoded
    }
}
