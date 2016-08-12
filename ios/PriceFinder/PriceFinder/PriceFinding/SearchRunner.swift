//
//  SearchRunner.swift
//  PriceFinder
//
//  Created by jacob stimes on 7/25/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation
import UIKit

/// SearchViewController should conform to this protocol to be notified when searching is finished, and get results
protocol SearchRunnerDelegate {
    func gotSearchResults(items: [Item]);
}

/// Wrapper around scrapers that can run a user's search and run background job to update prices and send out a notification
class SearchRunner {
    
    static var delegate: SearchRunnerDelegate?
    
    class func setSearchDelegate(aDelegate: SearchRunnerDelegate){
        delegate = aDelegate
    }
    
    class func search(query: String) {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            var items = [Item]();
            let scrapers = getAllScrapers();
            
            for scraper in scrapers {
                items.appendContentsOf(scraper.search(query));
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                delegate?.gotSearchResults(items);
            }
        }
    }
    
    class func backgroundFetch(completion: () -> Void) {
        let dc = DataController();
        let homeItems = dc.getHomeItems();
        
        var foundItemUnderTarget = false;
        
        for homeItem in homeItems {
            var items = [Item]();
            let scrapers = getAllScrapers();
            
            for scraper in scrapers {
                items.appendContentsOf(scraper.search(homeItem.title));
            }
            
            let savedItemMOs = dc.getItemsForGroupId(homeItem.groupId!);
            
            for savedItemMO in savedItemMOs {
                for foundItem in items {
                    if savedItemMO.vendor! == foundItem.vendor! && savedItemMO.title! == foundItem.title! {
                        
                        savedItemMO.link = foundItem.link!;
                        
                        //Only want to notify user if the prices were above target price before fetch (don't 
                        // re-notify them of the same item being found)
                        if savedItemMO.price > homeItem.targetPrice && foundItem.price <= homeItem.targetPrice {
                            foundItemUnderTarget = true;
                        }
                        
                        savedItemMO.price = foundItem.price;
                    }
                }
            }
            
            sleep(1); // API's limit the number of calls per second...
            
            dc.saveContext();
        }

        if foundItemUnderTarget  {
            sendNotification();
        }
        
        completion();
    }
    
	/// Configures and sends a notification to user
    private class func sendNotification() {
        let notification = UILocalNotification();
        notification.fireDate = NSDate(timeIntervalSinceNow: 5);
        notification.alertBody = "An item has been found below your target price!";
        notification.alertAction = nil;
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.userInfo = nil;
        UIApplication.sharedApplication().scheduleLocalNotification(notification);
    }
    
    private class func getAllScrapers() -> [ScraperProtocol] {
        return [BestBuyScraper(), WalmartScraper(), EbayScraper()];
    }
    
}