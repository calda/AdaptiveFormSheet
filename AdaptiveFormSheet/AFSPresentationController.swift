//
//  AFSPresentationController.swift
//  Adaptable-Form-Sheet
//
//  Created by Cal Stephens on 8/10/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit

public class AFSPresentationController : UIPresentationController {
    
    
    var animatedTransitioning: AFSAnimatedTransitioning?
    
    var options: AFSModalOptionsProvider? {
        return presentedViewController as? AFSModalOptionsProvider
    }
    
    
    //MARK: - Calculate Frame
    
    var contentSize: CGSize {
        return self.presentedViewController.preferredContentSize
    }
    
    var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    override public var frameOfPresentedViewInContainerView: CGRect {
        let availableSpace = availableSpaceWithPadding(top: statusBarHeight, bottom: 0)
        return rect(withSize: self.contentSize, centeredIn: availableSpace)
    }
    
    private func availableSpaceWithPadding(top: CGFloat, bottom: CGFloat) -> CGRect {
        var available = self.presentingViewController.view.bounds
        available.origin.y += top
        available.size.height -= (top + bottom)
        return available
    }
    
    private func rect(withSize size: CGSize, centeredIn container: CGRect) -> CGRect {
        let destinationOrigin = CGPoint(x: container.midX - (size.width / 2),
                                        y: container.midY - (size.height / 2))
        return CGRect(origin: destinationOrigin, size: size)
    }
    
    
    //MARK: - Animating Scrim
    
    var scrim: UIView?
    
    public override func presentationTransitionWillBegin() {
        createScrim()
        self.subscribeToKeyboardNotifications()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.scrim?.alpha = self.options?.backgroundDimmerOpacity ?? 0.4
        }, completion: nil)
    }
    
    public override func dismissalTransitionWillBegin() {
        self.presentedViewController.view.endEditing(true) //dismiss keyboard
        self.containerView?.isUserInteractionEnabled = false
        self.scrim?.isUserInteractionEnabled = false
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.scrim?.alpha = 0.0
        }, completion: { _ in
            self.unsubscribeFromKeyboardNotifications()
            self.scrim?.removeFromSuperview()
        });
    }
    
    
    //MARK: - Scrim / dimmer
    
    private func createScrim() {
        guard let containerView = self.containerView else { return }
        self.scrim = UIView(frame: containerView.bounds);
        guard let scrim = self.scrim else { return }
        
        scrim.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        scrim.alpha = 0.001
        scrim.isUserInteractionEnabled = true
        self.containerView?.addSubview(scrim)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.scrimTapped))
        tapRecognizer.delaysTouchesBegan = false
        scrim.addGestureRecognizer(tapRecognizer)
    }
    
    @objc private func scrimTapped() {
        guard options?.dismissWhenUserTapsDimmer != false else {
            return
        }
        
        if animatedTransitioning?.isAnimating == true {
            animatedTransitioning?.cancelTransition()
        } else {
            self.presentedViewController.dismiss(animated: true, completion: nil)
        }
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
        guard let presentedView = self.presentedView else { return }
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardStartFrame = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let keyboardAnimationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        
        //calculate frame with keyboard offset
        var newFrame: CGRect
        
        let keyboardTop = keyboardEndFrame.minY
        let keyboardHeight = containerView.frame.height - keyboardTop
        let availableSpace = availableSpaceWithPadding(top: statusBarHeight, bottom: keyboardHeight)
        
        let frameCenteredInAvailableSpace = rect(withSize: self.contentSize, centeredIn: availableSpace)
        newFrame = frameCenteredInAvailableSpace

        //if content can exist unclipped above the keyboard, center it in that space
        if (!availableSpace.contains(frameCenteredInAvailableSpace)) {
            
            //otherwise, ensure first responder is visible
            if let firstResponder = self.findFirstResponder(inView: self.presentedViewController.view) {
                
                var firstResponderRectInContainer = firstResponder.convert(firstResponder.bounds, to: containerView)
                
                //if the keyboard changed size, calculate where the firstResponder will go
                if (keyboardStartFrame != keyboardEndFrame) {
                    let offsetByKeyboard = presentedView.frame.origin.y - frameCenteredInAvailableSpace.origin.y
                    firstResponderRectInContainer.origin.y -= offsetByKeyboard
                }
                
                //if the first responder won't be visible, offset the origin
                if !(availableSpace.contains(firstResponderRectInContainer)) {
                    
                    if (firstResponderRectInContainer.minY < availableSpace.minY) { //if above status bar
                        let offset = firstResponder.bounds.minY
                        newFrame.origin.y = offset + statusBarHeight + 5
                    }
                    
                    else { //if under keyboard
                        let offset = abs(keyboardTop - firstResponderRectInContainer.maxY)
                        newFrame.origin.y -= (offset + 25)
                    }
                }
            }
            
        }
        
        UIView.animate(
            withDuration: keyboardAnimationDuration.doubleValue,
            delay: 0, options: [.beginFromCurrentState],
            animations: {
                self.presentedView?.frame = newFrame
            }, completion: nil)
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
