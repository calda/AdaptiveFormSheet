//
//  AFSAnimatedTransitioning.swift
//  Adaptable-Form-Sheet
//
//  Created by Cal Stephens on 8/10/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

public class AFSAnimatedTransitioning: NSObject  {
    
    public enum AnimationDirection {
        case presenting
        case dismissing
    }
    
    private let direction: AnimationDirection
    private var animator: NSObject? /* UIViewPropertyAnimator, only available on iOS >=10 */
    
    public init(direction: AnimationDirection) {
        self.direction = direction
    }
    
    private func options(from transitionContext: UIViewControllerContextTransitioning?) -> AFSModalOptionsProvider? {
        guard let transitionContext = transitionContext else { return nil }
        return transitionContext.viewController(forKey: .to) as? AFSModalOptionsProvider
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return options(from: transitionContext)?.animationDuration ?? 0.425
    }
    
}
    
// MARK: - Interactive Transition
// If iOS >= 10.0, the transition will be interruptable using UIViewPropertyAnimating
    
extension AFSAnimatedTransitioning: UIViewControllerInteractiveTransitioning {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        if #available(iOS 10.0, *) {
            interruptibleAnimator(using: transitionContext).startAnimation()
        } else {
            animateTransition(using: transitionContext)
        }
    }
    
    @available(iOS 10.0, *)
    public func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating
    {
        if let existingAnimator = self.animator as? UIViewPropertyAnimator {
            return existingAnimator
        }
        
        // Configure the participating view controllers
        guard let to = transitionContext.viewController(forKey: .to),
            let from = transitionContext.viewController(forKey: .from) else
        {
            fatalError("Could not find the expected view controllers.")
        }
        
        let container = transitionContext.containerView
        let duration = self.transitionDuration(using: transitionContext)
        
        if direction == .presenting {
            container.addSubview(to.view)
            (to.presentationController as? AFSPresentationController)?.animatedTransitioning = self
            
            to.view.frame = transitionContext.finalFrame(for: to)
                .translated(by: CGAffineTransform(
                    translationX: 0,
                    y: from.presentationContext.view.frame.height))
        }
        
        // Set up the animation
        let animator = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: 1.0,
            animations: {
                let destination = (self.direction == .presenting) ? to : from
                
                switch self.direction {
                case .presenting:
                    destination.view.frame = transitionContext.finalFrame(for: to)
                case .dismissing:
                    destination.view.frame = transitionContext.finalFrame(for: from)
                        .translated(by: CGAffineTransform(
                            translationX: 0,
                            y: to.presentationContext.view.frame.height))
                }
        })
        
        self.animator = animator
        animator.addCompletion { position in
            self.animator = nil
            transitionContext.completeTransition(position == .end)
        }
        
        return animator
    }
    
    var isAnimating: Bool {
        if #available(iOS 10.0, *), let animator = self.animator as? UIViewPropertyAnimator {
            return animator.isRunning && !animator.isReversed
        }
        
        return false
    }
    
    func cancelTransition() {
        if #available(iOS 10.0, *), let animator = self.animator as? UIViewPropertyAnimator {
            animator.isReversed = true
        }
    }
    
}


//MARK: - Fallback Presentation
// If UIViewPropertyAnimator is unavailable, fall back to an uninterruptable presentation

extension AFSAnimatedTransitioning: UIViewControllerAnimatedTransitioning {
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch(self.direction) {
        case .presenting: animatePresentation(using: transitionContext)
        case .dismissing: animateDismissal(using:transitionContext)
        }
    }
    
    private func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        guard let source = transitionContext.viewController(forKey: .from) else { return }
        
        let container = transitionContext.containerView
        let duration = self.transitionDuration(using: transitionContext)
        
        destination.view.frame = transitionContext.finalFrame(for: destination)
        destination.view.transform = CGAffineTransform(
            translationX: 0,
            y: source.presentationContext.view.frame.height)
        container.addSubview(destination.view)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [.allowUserInteraction, .allowAnimatedContent],
            animations: {
                destination.view.transform = CGAffineTransform.identity
            }, completion: { success in
                transitionContext.completeTransition(success)
        })
    }
    
    private func animateDismissal(using transitionContext:UIViewControllerContextTransitioning) {
        guard let dismissing = transitionContext.viewController(forKey: .from) else { return }
        guard let destination = transitionContext.viewController(forKey: .to) else { return }
        
        let duration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(
            withDuration: duration,
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0.0,
            options: [.allowUserInteraction],
            animations: {
                dismissing.view.transform = CGAffineTransform(
                    translationX: 0,
                    y: destination.presentationContext.view.frame.height)
            }, completion: { success in
                transitionContext.completeTransition(success)
        })
    }
    
}


// MARK: - CGRect.traslated(by: CGAffineTransform)

extension CGRect {
    func translated(by transform: CGAffineTransform) -> CGRect {
        return CGRect(
            x: self.origin.x + transform.tx,
            y: self.origin.y + transform.ty,
            width: self.width,
            height: self.height)
    }
}
