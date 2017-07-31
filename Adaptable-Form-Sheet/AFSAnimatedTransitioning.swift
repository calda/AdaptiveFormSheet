//
//  AFSAnimatedTransitioning.swift
//  Adaptable-Form-Sheet
//
//  Created by Cal Stephens on 8/10/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

public class AFSAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {
    
    
    //MARK: - Initializing with Direction
    
    public enum AnimationDirection {
        case presenting
        case dismissing
    }
    
    private let direction: AnimationDirection
    
    public init(direction: AnimationDirection) {
        self.direction = direction
    }
    
    
    //MARK: - UIViewControllerAnimatedTransitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch(self.direction) {
            case .presenting: animatePresentation(using: transitionContext)
            case .dismissing: animateDismissal(using:transitionContext)
        }
    }
    
    
    //MARK: - Animate depending on direction
    
    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        
        let container = transitionContext.containerView
        let duration = self.transitionDuration(using: transitionContext)
        
        destination.view.frame = transitionContext.finalFrame(for: destination)
        destination.view.transform = CGAffineTransform(translationX: 0, y: source.view.frame.height)
        container.addSubview(destination.view)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            destination.view.transform = CGAffineTransform.identity
            }, completion: { success in
                transitionContext.completeTransition(success)
        })
    }
    
    private func animateDismissal(using transitionContext:UIViewControllerContextTransitioning) {
        guard let dismissing = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: {
            dismissing.view.transform = CGAffineTransform(translationX: 0, y: destination.view.frame.height)
        }, completion: { success in
            transitionContext.completeTransition(success)
        })
    }
    
}
