//
//  DataController.swift
//  PriceFinder
//
//  Created by jacob stimes
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import Foundation
import CoreData

/*!
	@brief This class serves as a means of interacting with the CoreData database 
*/
class DataController : NSObject {
    
    var managedObjectContext: NSManagedObjectContext
    
    override init() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("PriceFinderDataModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc

        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let docURL = urls[urls.endIndex-1]
        /* The directory the application uses to store the Core Data store file.
         This code uses a file named "DataModel.sqlite" in the application's documents directory.
         */
        let storeURL = docURL.URLByAppendingPathComponent("DataModel.sqlite")
        do {
            try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil/*[NSMigratePersistentStoresAutomaticallyOption: true]*/);
        }
        catch {
            fatalError("Error migrating store: \(error)")
        }
    }
    
    func insertHomeItem(homeItem: HomeItem) -> SavedItemGroupMO {
        NSUserDefaults.standardUserDefaults().registerDefaults(["groupId":0]);
        
        homeItem.groupId = Int16(NSUserDefaults.standardUserDefaults().integerForKey("groupId"));
        NSUserDefaults.standardUserDefaults().setInteger(Int(homeItem.groupId!) + 1, forKey: "groupId");
        
        let group = NSEntityDescription.insertNewObjectForEntityForName("SavedItemGroup", inManagedObjectContext: self.managedObjectContext) as! SavedItemGroupMO;
        
        group.groupId = Int16(homeItem.groupId!);
        group.searchText = homeItem.title;
        group.targetPrice = homeItem.targetPrice;
        group.dateAdded = NSDate();
        
        for item in homeItem.items {
            let itemMO = NSEntityDescription.insertNewObjectForEntityForName("SavedItems", inManagedObjectContext: self.managedObjectContext) as! SavedItemMO;
            
            itemMO.groupId = group.groupId;
            itemMO.link = item.link;
            itemMO.vendor = item.vendor;
            itemMO.price = item.price;
            itemMO.title = item.title;
        }
        
        do {
            try managedObjectContext.save()
            NSLog("Saved");
        }
        catch {
            fatalError("Failure to save context: \(error)")
        }

        return group;
    }
    
    /// Intended for updating target price & removing items from homeItem
    func updateHomeItem(homeItem: HomeItem) {
        
        //Update target price:
        let homeItemFetch = NSFetchRequest(entityName: "SavedItemGroup");
        homeItemFetch.predicate = NSPredicate(format: "groupId == %d", homeItem.groupId!);
        
        var homeItemArray = [SavedItemGroupMO]();
        
        do {
            homeItemArray.appendContentsOf( try managedObjectContext.executeFetchRequest(homeItemFetch) as! [SavedItemGroupMO]);
            
            if homeItemArray.count != 1 {
                fatalError("The home item being updated must be in the database and there must be only one entry with that group id");
            }
            else {
                let savedItemGroupMO = homeItemArray.first;
                savedItemGroupMO?.targetPrice = homeItem.targetPrice;
                
                let savedItemMOs = getItemsForGroupId(savedItemGroupMO!.groupId);
                
                //Go through all entries in DB and see if they are still in existence
                for savedItemMO in savedItemMOs {
                    var deleted = true;
                    
                    for item in homeItem.items {
                        
                        if savedItemMO.vendor! == item.vendor! && savedItemMO.title! == item.title! {
                            //same item, still in homeItem's item list -- not been deleted
                            deleted = false;
                        }
                    }
                    
                    if deleted {
                        //savedItemMO was not found in homeItem's list of item's, user must have deleted it:
                        managedObjectContext.deleteObject(savedItemMO);
                    }
                }
            }
            
            try self.managedObjectContext.save();
        }
        catch {
            fatalError("'DataController.updatedHomeItem(...)' --- Failure to load items for group... or failed to save or load items");
        }

    }
    
    func getHomeItems() -> [HomeItem] {
        let moc = managedObjectContext
        let groupFetch = NSFetchRequest(entityName: "SavedItemGroup")
        
        var groups = [SavedItemGroupMO]();
        
        do {
            groups.appendContentsOf( try moc.executeFetchRequest(groupFetch) as! [SavedItemGroupMO] );
        }
        catch {
            fatalError("Failed to fetch groups: \(error)")
        }
        
        var homies = [HomeItem]();
        
        //Get items:
        for group in groups {
            
            let id = group.groupId;
 
            let itemMOs = self.getItemsForGroupId(id);
            var items = [Item]();
            
            for itemMO in itemMOs {
                
                let item = Item(title: itemMO.title!, price: itemMO.price, vendor: itemMO.vendor!, link: itemMO.link!);
                
                items.append(item);
            }
            
            let homeItem = HomeItem(groupId: group.groupId, title: group.searchText!, targetPrice: group.targetPrice, dateAdded: group.dateAdded, withItems: items);
            
            homies.append(homeItem);
            
        }
        
        
        return homies;
    }
    
    func getItemsForGroupId(id: Int16) -> [SavedItemMO] {
        let itemsFetch = NSFetchRequest(entityName: "SavedItems");
        itemsFetch.predicate = NSPredicate(format: "groupId == %d", id);
        
        var itemMOs = [SavedItemMO]();
        
        do {
            itemMOs.appendContentsOf( try managedObjectContext.executeFetchRequest(itemsFetch) as! [SavedItemMO]);
            
        }
        catch {
            fatalError("Failure to load items for group...");
        }
        
        return itemMOs;
    }
    
    func deleteHomeItem(homeItem: HomeItem){
        let moc = managedObjectContext
        let groupFetch = NSFetchRequest(entityName: "SavedItemGroup")
        
        let homeId = homeItem.groupId!;
        NSLog(String("Home id: " + String(homeId)));
        
        groupFetch.predicate = NSPredicate(format: "groupId == %d", homeItem.groupId!);
        
        var groups = [SavedItemGroupMO]();
        
        do {
            groups.appendContentsOf( try moc.executeFetchRequest(groupFetch) as! [SavedItemGroupMO] );
            
            if groups.count == 1 {
                let savedItemMOs = getItemsForGroupId(homeItem.groupId!);
                for savedItem in savedItemMOs {
                    managedObjectContext.deleteObject(savedItem);
                }
                
                managedObjectContext.deleteObject(groups.first!);
                try managedObjectContext.save()
                NSLog("Deleted");
            }
            else {
                NSLog(" NOT Deleted");
            }
        }
        catch {
            //return false
            fatalError("Failed to fetch groups: \(error)")
        }
    }
    
    func saveContext() {
        do {
            try managedObjectContext.save();
        }
        catch {
            fatalError("Failed to save context");
        }
    }
}
