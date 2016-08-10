//
//  AFSPresentationController.swift
//  Adaptable-Form-Sheet
//
//  Created by Cal Stephens on 8/10/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

public class AFSPresentationController : UIPresentationController {
    
    
    //MARK: - Calculate Frame
    
    var contentSize: CGSize {
        return self.presentedViewController.preferredContentSize
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        return rect(withSize: self.contentSize, centeredInRect: self.presentingViewController.view.bounds)
    }
    
    private func rect(withSize size: CGSize, centeredInRect rect: CGRect) -> CGRect {
        let destinationOrigin = CGPoint(x: (rect.size.width - size.width) / 2,
                                        y: (rect.size.height - size.height) / 2)
        return CGRect(origin: destinationOrigin, size: size)
    }
    
    
    //MARK: - Animating Scrim
    
    var scrim: UIView?
    
    public override func presentationTransitionWillBegin() {
        guard let containerView = self.containerView else { return }
        self.scrim = UIView(frame: containerView.bounds);
        guard let scrim = self.scrim else { return }
        
        scrim.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        scrim.alpha = 0.0
        self.containerView?.addSubview(scrim)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            scrim.alpha = 0.3
        }, completion: { _ in
            self.subscribeToKeyboardNotifications()
        });
    }
    
    public override func dismissalTransitionWillBegin() {
        guard let scrim = self.scrim else { return }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            scrim.alpha = 0.0
        }, completion: { _ in
            self.unsubscribeFromKeyboardNotifications()
            scrim.removeFromSuperview()
        });
    }
    
    
    //MARK: - Adapt based on changes to the container view
    
    public override func containerViewWillLayoutSubviews() {
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        
        if let containerView = self.containerView {
            self.scrim?.frame = containerView.bounds
        }
    }
    
    
    //MARK: - Adapt based on Keyboard presentation
    
    private func subscribeToKeyboardNotifications() {
        let selector = #selector(self.keyboardFrameWillChange(notification:))
        NotificationCenter.default.addObserver(self, selector: selector, name: .UIKeyboardWillChangeFrame, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardFrameWillChange(notification: NSNotification) {
        guard let containerView = self.containerView else { return }
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardStartFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardAnimationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        
        //calculate frame with keyboard offset
        var newFrame: CGRect
        
        let keyboardTop = keyboardEndFrame.minY
        let keyboardHeight = containerView.frame.height - keyboardTop
        let availableSize = CGSize(width: containerView.frame.width, height: containerView.frame.height - keyboardHeight)
        let availableSpace = CGRect(origin: CGPoint.zero, size: availableSize)
        
        let frameCenteredInAvailableSpace = rect(withSize: self.contentSize, centeredInRect: availableSpace)
        newFrame = frameCenteredInAvailableSpace

        //if content can exist unclipped above the keyboard, center it in that space
        if (!availableSpace.contains(frameCenteredInAvailableSpace)) {
            
            //otherwise, ensure first responder is visible
            if let firstResponder = self.findFirstResponder(inView: self.presentedViewController.view) {
                
                var firstResponderRectInContainer = firstResponder.convert(firstResponder.bounds, to: containerView)
                
                //if the keyboard changed size, calculate where the firstResponder will go
                if (keyboardStartFrame != keyboardEndFrame) {
                    let offsetByKeyboard = self.frameOfPresentedViewInContainerView.origin.y - frameCenteredInAvailableSpace.origin.y
                    firstResponderRectInContainer.origin.y -= offsetByKeyboard
                }
                
                //if the first responder won't be visible, offset the origin
                if !(availableSpace.contains(firstResponderRectInContainer)) {
                    
                    func makeResponderVisible(offset: CGFloat, usingOperator op: (CGFloat, CGFloat) -> CGFloat) {
                        let distanceToMove = abs(offset) + 25
                        let newOrigin = CGPoint(x: frameCenteredInAvailableSpace.origin.x,
                                                y: op(frameCenteredInAvailableSpace.origin.y, distanceToMove))
                        
                        newFrame = CGRect(origin: newOrigin, size: self.contentSize)
                    }
                    
                    if (firstResponderRectInContainer.minY < 20 /* if under status bar */) {
                        makeResponderVisible(offset: firstResponderRectInContainer.minY, usingOperator: +)
                    } else /* if under keyboard */ {
                        makeResponderVisible(offset: keyboardTop - firstResponderRectInContainer.maxY, usingOperator: -)
                    }
                }
            }
            
        }
        
        //animate
        UIView.animate(withDuration: keyboardAnimationDuration.doubleValue) {
            self.presentedView?.frame = newFrame
        }
    }
    
    private func findFirstResponder(inView view: UIView) -> UIView? {
        for subview in view.subviews {
            if subview.isFirstResponder {
                return subview
            } else {
                if let responder = findFirstResponder(inView: subview) {
                    return responder
                }
            }
        }
        
        return nil
    }
    
    
}
