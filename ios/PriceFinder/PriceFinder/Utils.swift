//
//  Utils.swift
//  PriceFinder
//
//  Created by jacob stimes on 5/26/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit

/// Just an assortment of commonly used values & functions
class Utils {
    
    static let babyBlueColor = UIColor(colorLiteralRed: 179.0 / 255.0, green: 229.0 / 255.0, blue: 252.0 / 255.0, alpha: 1.0);
    
    static let greenAccentColor = UIColor(colorLiteralRed: 148.0 / 255.0, green: 230.0 / 255.0, blue: 67.0 / 255.0, alpha: 1.0);
    
    static let greenPastelColor = UIColor(colorLiteralRed:0.867, green:0.965, blue: 0.867, alpha: 1);
    
    
    class func formatPrice(price: Double) -> String {
        return String(format:"$%.2f", price)
    }
    
    class func formatDate(date: NSDate) -> String {
        let formatter = NSDateFormatter();
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter.stringFromDate(NSDate())
    }
}
