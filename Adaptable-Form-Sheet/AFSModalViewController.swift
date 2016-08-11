//
//  AFSModalViewController.swift
//  Adaptable-Form-Sheet
//
//  Created by Cal Stephens on 8/10/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

public class AFSModalViewController : UIViewController, UIViewControllerTransitioningDelegate {
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupForTransition()
    }
    
    public required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setupForTransition()
    }
    
    func setupForTransition() {
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return AFSPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFSAnimatedTransitioning(direction: .presenting)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AFSAnimatedTransitioning(direction: .dismissing)
    }
    
}
