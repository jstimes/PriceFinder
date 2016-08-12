//
//  SearchResultTableViewCell.swift
//  PriceFinder
//
//  Created by jacob stimes on 5/26/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//
import UIKit

/// Cells used to display a results from a user's product search:
class SearchResultTableViewCell: UITableViewCell {
    
    // Company title:
    @IBOutlet weak var vendorLabel: UILabel!
    
    // Product price
    @IBOutlet weak var priceLabel: UILabel!
    
    // product title
    @IBOutlet weak var titleLabel: UILabel!
    
    // used for selecting whether or not the user wants to track this result
    @IBOutlet weak var checkbox: UIButton!
    
    // displays a product image if one exists
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    // Container for the cell content. has some margins and shadow to separate results a bit
    @IBOutlet weak var cardView: UIView!
    
    // item being shown
    var item: Item?
    
    /// Best place to configure the cardview
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.clipsToBounds = false;
        
        let shadowPath = UIBezierPath(rect: cardView.bounds)
        cardView.layer.masksToBounds = false
        cardView.layer.shadowColor = UIColor.blackColor().CGColor
        cardView.layer.shadowOffset = CGSizeMake(3.0, 3.0)
        cardView.layer.shadowRadius = 1;
        cardView.layer.shadowOpacity = 0.5
        cardView.layer.shadowPath = shadowPath.CGPath
    }

}
