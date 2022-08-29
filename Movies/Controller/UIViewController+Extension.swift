//
//  UIViewController.swift
//  Movies
//  Extend UIViewController with extra functionality.
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

// MARK: - Change safe area according to the area hidden by the keyboard

extension UIViewController {
  func startAvoidingKeyboard() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(_onKeyboardFrameWillChangeNotificationReceived(_:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification,
                                           object: nil)
  }
  
  func stopAvoidingKeyboard() {
    NotificationCenter.default.removeObserver(self,
                                              name: UIResponder.keyboardWillChangeFrameNotification,
                                              object: nil)
  }
  
  @objc private func _onKeyboardFrameWillChangeNotificationReceived(_ notification: Notification) {
    if #available(iOS 11.0, *) {
      guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
        return
      }
      
      let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
      let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
      let intersection = safeAreaFrame.intersection(keyboardFrameInView)
      
      let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
      
      UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
        self.additionalSafeAreaInsets.bottom = intersection.height
        self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }
}

// MARK: - Hide keyboard when touched outside

extension UIViewController {
  func hideKeyboardWhenTappedAround() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
}

