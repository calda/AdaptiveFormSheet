//
//  AFSModalViewController.swift
//  Adaptable-Form-Sheet
//
//  Created by Cal Stephens on 8/10/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

class AFSModalViewController : UIViewController, UIViewControllerTransitioningDelegate {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupForTransition()
    }
    
    required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupForTransition()
    }
    
    func setupForTransition() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AFSPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFSAnimatedTransitioning()
    }
    
}
