//
//  ConfirmationLabel.swift
//  PriceFinder
//
//  Created by jacob stimes on 8/6/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit

/// Subclasses UILabel to provide configurable edge insets (padding)
class ConfirmationLabel : UILabel {
    
    var edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, self.edgeInsets));
    }
    
    override func intrinsicContentSize() -> CGSize {
        let superContentSize = super.intrinsicContentSize()
        let width = superContentSize.width + edgeInsets.left + edgeInsets.right
        let heigth = superContentSize.height + edgeInsets.top + edgeInsets.bottom
        return CGSize(width: width, height: heigth)
    }
    
}
