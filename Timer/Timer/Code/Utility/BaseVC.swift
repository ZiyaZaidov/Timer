//
//  BaseVC.swift
//  Timer
//
//  Created by Ziya on 8/5/23.
//

import UIKit

class BaseVC: UIViewController {

    public var baseScrollView: UIScrollView?

    override func viewDidLoad() {
        super.viewDidLoad()

        baseScrollView?.canCancelContentTouches = false
        NotificationCenter.default.addObserver(self, selector: #selector(BaseVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(BaseVC.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func keyboardDidShow(heigh: CGFloat) {
        
    }
    
    func keyboardDidHide() {
        
    }

}
extension BaseVC {
    @objc func keyboardWillShow(notification: Notification) {
        guard let keyboardFrame: CGRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        let height = keyboardFrame.height + 200
        baseScrollView?.contentInset.bottom = height
        keyboardDidShow(heigh: height)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        baseScrollView?.contentInset = contentInsets
        baseScrollView?.scrollIndicatorInsets = contentInsets
        keyboardDidHide()
    }
}
