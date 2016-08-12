//
//  SearchTableViewController.swift
//  PriceFinder
//
//  Created by jacob stimes on 5/22/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit
import Foundation

/*!
 @brief Users can type in a keyword search for a product,
        upon hitting search, the query will
        be sent to SearchRunner to go through all
        available scrapers, and resulting items are displayed 
        for user to selectd from. Users pick one of more results 
        to be tracked, and then select 'Add to Find List',
        choose a target price they want to purchase at or below,
        and then the search group is saved to CoreData
 */
class SearchTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, SearchRunnerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var searchResults = [Item]()
    
    var selectedIndices = [Bool]()
    var selections = 0;
    
    let MAX_PRICE: Int = 2500;
    
    let DEFAULT_PRICE: Int = 50;
    
    let BG_COLOR = Utils.babyBlueColor;
    
    var popupHeight: CGFloat = 0;
    
    var popupOpen = false;
    
    var topTextOnScreen = true;
    
    var confirmationLabel: ConfirmationLabel?;
    
    var isSearching = false;
    
    var popupSlideDuration: NSTimeInterval = 0;
    
    var noResults = false;
    
    //Maintain a strong reference for when it's removed
    @IBOutlet var tableHeaderView: UIView!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var topTextViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topTextView: UIView!
    var tableViewToBottomConstraint: NSLayoutConstraint!
    @IBOutlet var tableViewAndPopupConstraint: NSLayoutConstraint!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterAndCancelButton: UIButton!
    @IBOutlet weak var addToFindListAndConfirmButton: UIButton!
    @IBOutlet weak var pricePickerView: UIPickerView!
    @IBOutlet weak var popupBottomConstraint: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        //self.tableView.backgroundColor = BG_COLOR;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 100;
        
        self.pricePickerView.dataSource = self;
        self.pricePickerView.delegate = self;
        
        self.selectedIndices = [Bool].init(count: self.searchResults.count, repeatedValue: false);
        
        self.definesPresentationContext = true;
        self.searchController.delegate = self;
        
        self.navigationItem.titleView = self.searchController.searchBar;
        self.searchController.hidesNavigationBarDuringPresentation = false;
        self.searchController.searchBar.searchBarStyle = UISearchBarStyle.Default;
        
        self.searchController.searchBar.delegate = self;
        self.searchController.searchBar.sizeToFit();
        self.searchController.dimsBackgroundDuringPresentation = false;
        
        SearchRunner.setSearchDelegate(self)
        
        self.loadingIndicator.backgroundColor = UIColor.clearColor();
        
        self.tableHeaderView.addSubview(loadingIndicator);
        self.loadingIndicator.frame = self.tableHeaderView.bounds;
        self.loadingIndicator.autoresizingMask = [.FlexibleWidth, .FlexibleHeight];
        
        //Don't show until user searches
        self.tableView.tableHeaderView = nil;
        
        self.popupHeight = self.view.frame.size.height / 2.0;
        self.closePopup(false);
        self.popupSlideDuration = 0.4;
        
        self.addToFindListAndConfirmButton.enabled = false;
        
        self.addPopupViewBorder();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source and delegate

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.noResults {
            self.tableView.scrollEnabled = false;
            return 1;
        }
        else {
            self.tableView.scrollEnabled = true;
            return searchResults.count
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.noResults {
            let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "noResults");
            cell.textLabel!.text = "No results found";
            cell.selectionStyle = .None;
            return cell;
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Search", forIndexPath: indexPath) as! SearchResultTableViewCell
        
        cell.backgroundColor = BG_COLOR;
        
        let item = searchResults[indexPath.row];
        cell.item = item;
        cell.titleLabel.text = item.title;
        cell.priceLabel.text = Utils.formatPrice(item.price);
        cell.vendorLabel.text = item.vendor;
        //cell.descriptionLabel.text = item.description;
        
        cell.cardView.alpha = 1;
        
        if selectedIndices[indexPath.row] {
            cell.checkbox.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal);
        }
        else {
            cell.checkbox.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal);
        }

        cell.checkbox.imageView?.tintColor = Utils.greenAccentColor;
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None;
        
        //Load a thumbnail image to display:
        if item.thumbnailLink != "" {
            let url = NSURL(string: item.thumbnailLink!);
            cell.thumbnailImageView.image = UIImage(named: "placeHolderImage");
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let data = NSData(contentsOfURL: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check
                dispatch_async(dispatch_get_main_queue(), {
                    if cell.item?.link == item.link {
                        cell.thumbnailImageView.image = UIImage(data: data!);
                    }
                });
            }
        }
        else {
            cell.thumbnailImageView.image = UIImage(named: "noImageAvailable");
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if noResults {
            return;
        }
        
        self.selectedIndices[indexPath.row] = !self.selectedIndices[indexPath.row];
        
        if self.selectedIndices[indexPath.row] {
            
            if self.selections == 0 {
                self.addToFindListAndConfirmButton.enabled = true
            }
            
            self.selections = selections + 1;
        }
        
        if !selectedIndices[indexPath.row] {
            selections = selections - 1;
            
            if selections == 0 {
                addToFindListAndConfirmButton.enabled = false;
                
                if popupOpen {
                    //Don't allow user to add 0 items:
                    closePopup(false);
                }
            }
        }
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! SearchResultTableViewCell;
        
        if self.selectedIndices[indexPath.row] {
            cell.checkbox.setImage(UIImage(named: "ic_check_box")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal);
        }
        else {
            cell.checkbox.setImage(UIImage(named: "ic_check_box_outline_blank")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal);
        }

        cell.checkbox.imageView?.tintColor = Utils.greenAccentColor;
    }
    
    // MARK - SearchRunnerDelegate
    
    /// Called when SearchRunner is finished searching for uses query. items contain the search results
    func gotSearchResults(items: [Item]) {
        if !self.isSearching {
            //Cancel was pressed, just ignore results:
            return;
        }
        
        self.isSearching = false;
        self.loadingIndicator.stopAnimating();
        self.tableView.tableHeaderView = nil;
        
        self.noResults = items.count == 0;
        
        self.searchResults.removeAll();
        self.selectedIndices.removeAll();
        
        self.searchResults.appendContentsOf(items);
        self.selectedIndices = [Bool].init(count: self.searchResults.count, repeatedValue: false);
        
        let range = NSMakeRange(0, self.tableView.numberOfSections);
        let sections = NSIndexSet(indexesInRange: range);
        self.tableView.reloadSections(sections, withRowAnimation: .Bottom);
    }

    /*
    // Override to support rearranging the table view. - May be useful if I want to allow user to have sorting options (by price, company, relevance, etc.)
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /// Fires the search!
    func searchBarSearchButtonClicked( searchBar: UISearchBar)
    {
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchBar.resignFirstResponder();
        SearchRunner.search(searchBar.text!);
        
        self.isSearching = true;
        self.tableView.tableHeaderView = self.tableHeaderView;
        self.loadingIndicator.startAnimating();
        
    }
    
    /// Once user starts typing a search, remove information label from top
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        if self.topTextOnScreen {
            self.topTextOnScreen = false;
            
            self.topTextView.layoutIfNeeded();
            self.tableView.layoutIfNeeded();
            
            UIView.animateWithDuration(self.popupSlideDuration, animations: {
                self.topTextViewTopConstraint.constant -= self.topTextView.frame.size.height;
                self.topTextView.layoutIfNeeded();
                self.tableView.layoutIfNeeded();
            });
            
        }
    }
    
    /// Cancel/clear callback for searchbar. Clears results, resets View controller's state, and redisplays information label at top
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.topTextOnScreen = true;
        
        self.searchResults.removeAll();
        self.selectedIndices.removeAll();
        self.noResults = false;
        self.tableView.reloadData();
        
        self.selections = 0;
        self.addToFindListAndConfirmButton.enabled = false;
        
        self.topTextView.layoutIfNeeded();
        self.tableView.layoutIfNeeded();
        self.searchController.searchBar.layoutIfNeeded();
        
        UIView.animateWithDuration(self.popupSlideDuration, animations: {
            self.topTextViewTopConstraint.constant += self.topTextView.frame.size.height;
            self.topTextView.layoutIfNeeded();
            self.tableView.layoutIfNeeded();
            self.searchController.searchBar.layoutIfNeeded();
        });
        
        if self.isSearching {
            isSearching = false;
            self.loadingIndicator.stopAnimating();
            self.tableView.tableHeaderView = nil;
        }
    }
    
    /*!
        @brief Animates the popup sliding back down.
        @param confirmed: If true, displays the confirmation label when popup is done animating
    */
    func closePopup(confirmed: Bool){
        self.popupOpen = false;
        
        let height = popupHeight - (addToFindListAndConfirmButton.frame.size.height + self.tabBarController!.tabBar.frame.size.height + 4);
        
        self.popupBottomConstraint.constant = self.popupBottomConstraint.constant + height;
        self.popupView.setNeedsUpdateConstraints();
        
        addToFindListAndConfirmButton.hidden = true;
        addToFindListAndConfirmButton.setTitle("Add to Find List", forState: .Normal);
        addToFindListAndConfirmButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents);
        addToFindListAndConfirmButton.addTarget(self, action: #selector(addToFindListButtonClicked), forControlEvents: UIControlEvents.TouchUpInside);
        
        self.filterAndCancelButton.hidden = true;
        self.filterAndCancelButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents);
        self.filterAndCancelButton.setTitle("Sort", forState: .Normal);
        //add target
        
        UIView.animateWithDuration(popupSlideDuration, animations: {
                self.view.layoutIfNeeded();
            }, completion: { (finished: Bool) in
                self.addToFindListAndConfirmButton.hidden = false;
                if confirmed {
                    ////Trigger the 'cancel' callback to clear table and input
                    //self.searchBarCancelButtonClicked(self.searchController.searchBar);
                    
                    self.showConfirmationMessage();
                }
            }
        );
    }
    
    /// 'Cancel' callback when popup is open
    func addCancelled(){
        self.closePopup(false);
    }
    
    /// Upon clicking 'Add to Find List', the bottom price picking popup slides up from the bottom
    func addToFindListButtonClicked(){
        self.popupOpen = true;
        
        self.pricePickerView.selectRow(DEFAULT_PRICE, inComponent: 0, animated: false);
        
        let afterHeight = addToFindListAndConfirmButton.frame.size.height + self.tabBarController!.tabBar.frame.size.height + 4
        let trans = popupHeight - afterHeight;
        
        self.addToFindListAndConfirmButton.hidden = true;
        self.addToFindListAndConfirmButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents);
        self.addToFindListAndConfirmButton.setTitle("Confirm", forState: .Normal);
        self.addToFindListAndConfirmButton.addTarget(self, action: #selector(targetPriceWasSet), forControlEvents: .TouchUpInside);
        
        self.filterAndCancelButton.hidden = true;
        self.filterAndCancelButton.setTitle("Cancel", forState: .Normal);
        self.filterAndCancelButton.removeTarget(nil, action: nil, forControlEvents: .AllEvents);
        self.filterAndCancelButton.addTarget(self, action: #selector(addCancelled), forControlEvents: .TouchUpInside);
        
        self.popupBottomConstraint.constant = self.popupBottomConstraint.constant - trans;
        
        UIView.animateWithDuration(popupSlideDuration,
            animations: {
                self.view.layoutIfNeeded();
            },
            completion: {
                (value: Bool) in
                self.filterAndCancelButton.hidden = false;
                self.addToFindListAndConfirmButton.hidden = false;
            }
        );
    }
    
    /// Called after user presses 'Confirm' to save a search. Items get stored into CoreData, and will appear in user's home list
    func targetPriceWasSet(){
        var chosenOnes = [Item]();
        let price = Double(pricePickerView.selectedRowInComponent(0));
        
        for i in 0..<searchResults.count {
            if selectedIndices[i] {
                chosenOnes += [searchResults[i]];
            }
        }
        
        let homeItem = HomeItem(title: searchController.searchBar.text!, targetPrice: price, withItems: chosenOnes);
        DataController().insertHomeItem(homeItem);
        
        self.closePopup(true);
    }
    
    /// Displays a popup over the screen content in the view's center. Intended to look similar to system popups
    func showConfirmationMessage(){
        confirmationLabel = ConfirmationLabel.init();
        
        confirmationLabel!.text = "Items added to\nyour Find List!";
        confirmationLabel!.numberOfLines = 2;
        confirmationLabel!.textAlignment = .Center;
        
        confirmationLabel!.backgroundColor = UIColor.darkGrayColor();
        confirmationLabel!.alpha = 0.93;
        
        confirmationLabel!.clipsToBounds = true;
        confirmationLabel!.layer.cornerRadius = 8;
        
        let padding: CGFloat = 8.0;
        confirmationLabel!.edgeInsets.bottom = padding;
        confirmationLabel!.edgeInsets.top = padding;
        confirmationLabel!.edgeInsets.left = padding * 2;
        confirmationLabel!.edgeInsets.right = padding * 2;
        
        confirmationLabel!.textColor = UIColor.whiteColor();
        confirmationLabel!.font = confirmationLabel!.font.fontWithSize(20);
        
        confirmationLabel!.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(confirmationLabel!);
        
        let xConstraint = NSLayoutConstraint(item: confirmationLabel!, attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1, constant: 0);
        let yConstraint = NSLayoutConstraint(item: confirmationLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: self.view, attribute: .CenterY, multiplier: 1, constant: 0);
        NSLayoutConstraint.activateConstraints([xConstraint, yConstraint]);
        
        NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(removeConfirmationLabel), userInfo: nil, repeats: false);
    }
    
    /// Animates the confirmation popup fading out
    func removeConfirmationLabel() {
        UIView.animateWithDuration(0.4, animations: {
            self.confirmationLabel!.alpha = 0;
            }, completion: {
                (completed: Bool) in
                self.confirmationLabel!.removeFromSuperview();
                self.confirmationLabel = nil;
        });
    }
    
    
    //MARK Picker view delegate & data source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MAX_PRICE
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
    
    /// Places a border at the top of the popupview
    private func addPopupViewBorder() {
        let borderLayer = CALayer.init();
        
        let borderWidth: CGFloat = 2;
        
        //let rect = self.view.convertRect(self.popupView.frame, toView: self.view);
        
        borderLayer.frame = CGRectMake(0, 0, self.popupView.frame.size.width, borderWidth);
        
        borderLayer.backgroundColor = UIColor.darkGrayColor().CGColor;
        
        self.popupView.layer.addSublayer(borderLayer);
    }
    
}






