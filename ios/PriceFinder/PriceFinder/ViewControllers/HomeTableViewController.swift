//
//  HomeController.swift
//  PriceFinder
//
//  Created by jacob stimes on 5/22/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit

///Displays a user's saved item searches. Tapping one takes them to more detailed view
class HomeTableViewController: UITableViewController {
    
    var noHomeItems = false;

    //Maintain strong ref so it doesn't get deallocated when removed
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var profileItems = [HomeItem]();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        self.navigationItem.rightBarButtonItem = editButtonItem();
        
        self.tabBarItem.title = "Find List";
        
        self.loadingIndicator.backgroundColor = UIColor.clearColor();
        
        self.loadingIndicator.startAnimating();
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
            SearchRunner.backgroundFetch({
                dispatch_async(dispatch_get_main_queue()) {
                    self.loadingIndicator.stopAnimating();
                    self.tableView.tableHeaderView = nil;
                    self.loadItems();
                }
            });
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        loadItems();
    }
    
	///Gets items from CoreData
    func loadItems() {
        let loadedItems = DataController().getHomeItems();
        
        //Sort so that those with the largest value of (targetPrice - lowestPrice) are at top:
        // i.e. the biggest deals show up at top:
        self.profileItems = loadedItems.sort( { (first: HomeItem, second: HomeItem ) -> Bool in
            let firstDiff = first.targetPrice - first.lowestPrice;
            let secondDiff = second.targetPrice - second.lowestPrice;
            
            return firstDiff > secondDiff;
        });
        
        if self.profileItems.count == 0 {
            noHomeItems = true;
        }
        else {
            noHomeItems = false;
        }
        
        self.tableView.reloadData();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning();
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if noHomeItems {
            self.tableView.separatorStyle = .None;
            self.tableView.scrollEnabled = false;
            return 1;
        }
        else {
            self.tableView.separatorStyle = .SingleLine;
            self.tableView.scrollEnabled = true;
            return profileItems.count;
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if noHomeItems {
            let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "noHomeItems");
            let italicString = NSMutableAttributedString(string: "No items in Find List", attributes: [NSFontAttributeName: UIFont.italicSystemFontOfSize(UIFont.labelFontSize())]);
            cell.textLabel!.attributedText = italicString;
            cell.selectionStyle = .None;
            return cell;
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Home", forIndexPath: indexPath) as! HomeItemTableViewCell;
        
        let homeItem = profileItems[indexPath.row];
        cell.titleLabel.text = homeItem.title;

        cell.targetPriceLabel.text = "Target price: " + Utils.formatPrice(homeItem.targetPrice!);
        
        if(homeItem.lowestPrice <= homeItem.targetPrice){
            cell.backgroundColor = Utils.greenPastelColor;
        }
        else {
            cell.backgroundColor = UIColor.whiteColor();
        }
        
        cell.lowestPriceLabel.text = "Lowest price: " + Utils.formatPrice(homeItem.lowestPrice);
        
        return cell;
    }

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if noHomeItems {
            return false;
        }
        
        return true;
    }
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source:            
            DataController().deleteHomeItem(self.profileItems[indexPath.row]);
            
            self.profileItems.removeAtIndex(indexPath.row);
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade);
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    
    // MARK: - Navigation
    
    // Segue to detail view controller:
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        let vc = segue.destinationViewController as! HomeItemDetailViewController;
        let index = self.tableView!.indexPathForSelectedRow!.row;
        let selectedHomeItem = self.profileItems[index];
        
        vc.homeItem = selectedHomeItem;
    }
 
    
}
