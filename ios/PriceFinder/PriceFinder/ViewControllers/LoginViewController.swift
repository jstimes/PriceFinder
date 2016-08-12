//
//  LoginViewController.swift
//  PriceFinder
//
//  Created by jacob stimes on 7/6/16.
//  Copyright © 2016 stimes.enterprises. All rights reserved.
//

import UIKit
import Foundation

/*! 
 @brief At one point I envisioned users actually logging in to a server...
    ...until I realized I don't want to develop, configure, deploy, and maintain a server...
    just a splash screen now. Shows some animations then gives control to the tabBar controller
 */
class LoginViewController: UIViewController {
    
    @IBOutlet weak var finderLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var priceCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var finderCenterYConstraint: NSLayoutConstraint!
    
    var constraintUpdate: CGFloat?;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //3/4's of the view height
        constraintUpdate = (self.view.frame.size.height / 2.0) + (self.view.frame.size.height / 4.0);
        
        //Put the labels off-screen and transparent to begin
        priceCenterYConstraint.constant = constraintUpdate!;
        finderCenterYConstraint.constant = -constraintUpdate!;
        priceLabel.alpha = 0.0;
        finderLabel.alpha = 0.0;
        
        priceLabel.textAlignment = .Right;
        finderLabel.textAlignment = .Left;
        
        //Sets an image overlay for the view controller's background
        UIGraphicsBeginImageContext(self.view.frame.size);
        UIImage(named: "priceFinderBGcolor.png")!.drawInRect(self.view.bounds);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        self.view.backgroundColor = UIColor.init(patternImage: image);
    }
    
    // Begins animations once view is on screen
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated);
        
        self.slideIntoPlaceAnimation();
    }
    
    //Animates price label coming up from bottom, finder label coming down from top,
    // and both becoming opaque
    // Triggers fade out animation on completion
    func slideIntoPlaceAnimation() {
        
        //For animating constraints, 
        // set desired contraints before animation block,
        // and just call layoutIfNeeded in animation block
        self.priceCenterYConstraint.constant -= constraintUpdate!;
        self.finderCenterYConstraint.constant += constraintUpdate!;
        
        UIView.animateWithDuration(1.2,
                                   delay: 0,
                                   options: UIViewAnimationOptions.CurveEaseOut,
                                   animations: {
                                    self.view.layoutIfNeeded();
                                    self.priceLabel.alpha = 1.0;
                                    self.finderLabel.alpha = 1.0;
            }, completion: {
                (value: Bool) in
                    self.fadeOutAnimation();
            }
        );
    }
    
    //Animates the labels fading out
    // on completion, triggers seque to tabbarcontroller
    func fadeOutAnimation(){
        UIView.animateWithDuration(0.4,
                                   delay: 0.35,
                                   options: UIViewAnimationOptions.TransitionNone,
                                   animations: {
                                    self.priceLabel.alpha = 0;
                                    self.finderLabel.alpha = 0;
            }, completion: {
                (value: Bool) in
                self.performSegueWithIdentifier("SplashToTabsSeque", sender: self);
            }
        );
    }

}
