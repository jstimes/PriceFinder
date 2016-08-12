//
//  HomeItemDetailTableViewCell.swift
//  PriceFinder
//
//  Created by jacob stimes on 7/30/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit

/// Very similar to a search result table view cell, without the checkbox. Still haven't swapped out the description for a thumbnail image
class HomeItemDetailTableViewCell : UITableViewCell {
    
    @IBOutlet weak var cardView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
   
    // Used to ensure views have an appropriate width and labels aren't cut off
    @IBOutlet weak var priceAndCompanyStackViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var companyLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.priceAndCompanyStackViewWidthConstraint.constant = self.companyLabel.frame.size.width;
        
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