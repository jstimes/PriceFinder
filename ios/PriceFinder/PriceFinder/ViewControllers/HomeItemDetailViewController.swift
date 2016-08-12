//
//  HomeItemDetailViewController.swift
//  PriceFinder
//
//  Created by jacob stimes on 6/12/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit

/*!
 @brief Displays the information and selected items associated with a 'HomeItem' a user is tracking.
    User can select 'Edit' and then adjust the target price or delete items from the search
 */
class HomeItemDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    //Item being showcased:
    var homeItem: HomeItem?;

    let MAX_PRICE: Int = 2500;
    
    @IBOutlet weak var titleLabel: UILabel!;
    
    @IBOutlet weak var itemTableView: UITableView!;
    
    @IBOutlet weak var targetLabel: UILabel!;
    
    @IBOutlet weak var targetPricePickerWidthConstraint: NSLayoutConstraint!;
    
    @IBOutlet weak var lowestPriceLabel: UILabel!;
    
    @IBOutlet weak var dateAddedLabel: UILabel!;
    
    @IBOutlet weak var targetPriceEditPicker: UIPickerView!;
    
    override func viewDidLoad() {
        
        self.navigationItem.rightBarButtonItem = editButtonItem();
        
        self.itemTableView.delegate = self;
        self.itemTableView.dataSource = self;
        
        //No way homeItem should be nil if we're viewing its details...
        self.titleLabel.text = homeItem!.title;
        self.lowestPriceLabel.text = Utils.formatPrice((homeItem!.lowestPrice)!);
        self.targetLabel.text = Utils.formatPrice((homeItem!.targetPrice)!);
        self.dateAddedLabel.text = Utils.formatDate(homeItem!.dateAdded!);
        
        self.itemTableView.rowHeight = UITableViewAutomaticDimension;
        self.itemTableView.estimatedRowHeight = 128;
        
        self.targetPriceEditPicker.delegate = self;
        self.targetPriceEditPicker.dataSource = self;
        
        self.setTableViewTopBorder();
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated);
        
        if editing {
            
            //Swap label and picker views:
            self.targetPricePickerWidthConstraint.constant = self.targetLabel.frame.size.width;
            self.targetPriceEditPicker.hidden = false;
            self.targetPriceEditPicker.selectRow(Int(self.homeItem!.targetPrice), inComponent: 0, animated: true);
            self.targetLabel.hidden = true;
            
            //Enable table editing:
            self.itemTableView.setEditing(true, animated: true);
        }
        else {
            //Display new target price & save any updates to CoreData:
            let newTargetPrice = Double(self.targetPriceEditPicker.selectedRowInComponent(0));
            self.targetLabel.text = Utils.formatPrice(newTargetPrice);
            self.homeItem!.targetPrice = newTargetPrice;
            DataController().updateHomeItem(self.homeItem!);
            
            //Swap hidden views:
            self.targetPriceEditPicker.hidden = true;
            self.targetLabel.hidden = false;
            
            //Disable table editing & update backgrounds if items are now above or below target price:
            self.itemTableView.setEditing(false, animated: true);
            self.itemTableView.reloadData();
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = self.homeItem?.items.count {
            return num;
        }
        
        return 0;
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HomeItemDetailCell", forIndexPath: indexPath) as! HomeItemDetailTableViewCell;
        
        let item = self.homeItem!.items[indexPath.row];
        cell.titleLabel.text = item.title!.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        );
        
        cell.priceLabel.text = Utils.formatPrice(item.price);
        cell.companyLabel.text = item.vendor;
        
        cell.cardView.alpha = 1;
        
        if item.price <= self.homeItem!.targetPrice {
            cell.cardView.backgroundColor = Utils.greenPastelColor;
        }
        else {
            cell.cardView.backgroundColor = UIColor.whiteColor();
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        return cell
    }
    
    //Ask if user wants to go view the website when an item is selected
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let alertController = UIAlertController(title: "Open in browser?", message: nil, preferredStyle: UIAlertControllerStyle.Alert);
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            alertController.dismissViewControllerAnimated(true, completion: nil);
        }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (result : UIAlertAction) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: self.homeItem!.items[indexPath.row].link!)!);
        }
        
        alertController.addAction(cancelAction);
        alertController.addAction(okAction);
        
        self.presentViewController(alertController, animated: true, completion: nil);
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            self.homeItem!.items.removeAtIndex(indexPath.row);
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade);
            
            if self.homeItem!.items.count == 0 {
                //User deleted all items, remove home item from find list and dismiss the details view
                DataController().deleteHomeItem(self.homeItem!);
                
                self.navigationController!.popViewControllerAnimated(true);
            }
        }
    }
    
    //MARK: Picker view delegate & data source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MAX_PRICE;
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row);
    }
    
    
    // Places a border at the bottom of the top information view (aka top of table view).
    //  Placing it at (0,0) in tableview will cause it to scroll with tableview, so
    //  that's why it's added to self.view
    private func setTableViewTopBorder() {
        let borderLayer = CALayer.init();
        
        let borderWidth: CGFloat = 2;
        
        let rect = self.view.convertRect(self.itemTableView.frame, toView: self.view);
        
        borderLayer.frame = CGRectMake(0, rect.origin.y - borderWidth, self.itemTableView.frame.size.width, borderWidth);
        
        borderLayer.backgroundColor = UIColor.blackColor().CGColor;
        
        self.view.layer.addSublayer(borderLayer);
    }
    
}
