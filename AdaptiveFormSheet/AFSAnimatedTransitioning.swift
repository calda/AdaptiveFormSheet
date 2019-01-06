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
    private var animator: UIViewPropertyAnimator?
    
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
    
extension AFSAnimatedTransitioning: UIViewControllerInteractiveTransitioning {
    
    public func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    public func interruptibleAnimator(
        using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating
    {
        if let existingAnimator = self.animator {
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
        if let animator = self.animator {
            return animator.isRunning && !animator.isReversed
        }
        
        return false
    }
    
    func cancelTransition() {
        if let animator = self.animator {
            animator.isReversed = true
        }
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
