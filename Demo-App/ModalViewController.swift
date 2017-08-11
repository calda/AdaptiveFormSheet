//
//  ModalViewController.swift
//  Adaptable-Form-Sheet
//
//  Created by Cal Stephens on 8/11/16.
//  Copyright © 2016 Cal Stephens. All rights reserved.
//

import UIKit
import AdaptiveFormSheet

class ModalViewController : AFSModalViewController {
    
    @IBOutlet var textFields: [UITextField]!
    
    @IBAction func resignResponder(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func dismiss(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nextPressed(_ sender: UITextField) {
        let nextField = nextTextFieldForTag(tag: sender.tag)
        nextField?.becomeFirstResponder()
    }
    
    func nextTextFieldForTag(tag: Int) -> UITextField? {
        var nextTag = tag + 1
        if nextTag > 2 { nextTag = 1}
        
        return textFields.first(where: { $0.tag == nextTag })
    }
    
}
