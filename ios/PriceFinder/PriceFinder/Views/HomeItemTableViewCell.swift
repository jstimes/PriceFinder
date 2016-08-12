//
//  HomeItemTableViewCell.swift
//  PriceFinder
//
//  Created by jacob stimes on 5/26/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit

/// Cells displayed on Home tab. Just contains the high-level info about a saved item search
class HomeItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var targetPriceLabel: UILabel!

    @IBOutlet weak var lowestPriceLabel: UILabel!
}
