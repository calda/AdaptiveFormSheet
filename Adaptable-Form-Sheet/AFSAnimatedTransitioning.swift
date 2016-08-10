//
//  AFSAnimatedTransitioning.swift
//  Adaptable-Form-Sheet
//
//  Created by Cal Stephens on 8/10/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

public class AFSAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.viewController(forKey: UITransitionContextToViewControllerKey) else { return }
        guard let source = transitionContext.viewController(forKey: UITransitionContextFromViewControllerKey) else { return }
        
        let container = transitionContext.containerView
        let duration = self.transitionDuration(using: transitionContext)
        
        destination.view.frame = transitionContext.finalFrame(for: destination)
        destination.view.transform = CGAffineTransform(translationX: 0, y: source.view.frame.height)
        container.addSubview(destination.view)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            destination.view.transform = CGAffineTransform.identity
        }, completion: { success in
            transitionContext.completeTransition(success)
        })
    }
    
}
