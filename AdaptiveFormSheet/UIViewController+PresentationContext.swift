//
//  UIViewController+PresentationContext.swift
//  AdaptiveFormSheet
//
//  Created by Cal Stephens on 9/21/18.
//  Copyright © 2018 Cal Stephens. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Finds the parent View Controller that defines the presentation context
    var presentationContext: UIViewController {
        var contextDefiningViewController = self
        
        while !contextDefiningViewController.definesPresentationContext,
            let nextParent = contextDefiningViewController.presentingViewController
        {
            contextDefiningViewController = nextParent
        }
        
        return contextDefiningViewController
    }
    
}
