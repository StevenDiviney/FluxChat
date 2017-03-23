//
//  ZDUIViewController.swift
//  SupportChat
//
//  Created by Steven Diviney on 2/16/16.
//  Copyright © 2016 Zendesk. All rights reserved.
//

import UIKit

class ZDUIViewController: UIViewController {
    var keyboardHeight: CGFloat
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    required init?(coder aDecoder: NSCoder) {
        keyboardHeight = 0
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ZDUIViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ZDUIViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ note: Notification) {
        let userInfo = (note as NSNotification).userInfo
        
        var keyboardBounds = (userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        keyboardBounds = convertKeyboardBoundsToViewCoordinates(keyboardBounds!)
        
        self.keyboardHeight = keyboardBounds!.size.height
        self.bottomLayoutConstraint.constant = self.keyboardHeight
        
        updateWithAnimation()
        
    }
    
    func keyboardWillHide(_ note: Notification) {
        self.keyboardHeight = 0
        self.bottomLayoutConstraint.constant = self.keyboardHeight
        
        self.updateWithAnimation()
    }
    
    func convertKeyboardBoundsToViewCoordinates(_ keyboardBounds: CGRect) -> CGRect {
        return contentView!.convert(keyboardBounds, from: nil)
    }
    
    func updateWithAnimation() {
        //let animationDuration = NSTimeInterval(integerLiteral: userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Int64) //Ehhhh
        //let animationCurve =  userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UIViewAnimationOptions
        
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
            self.contentView.layoutIfNeeded()
            }, completion: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}
