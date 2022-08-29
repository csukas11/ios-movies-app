//
//  LoadingSpinner.swift
//  Movies
//
//  Draws a loading spinner with a partly transparent background to the given view.
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

class LoadingSpinner {
  
  // MARK: - Properties
  
  fileprivate var loadingSpinner: UIView? = nil
  fileprivate var parentView: UIView
  
  // MARK: - Funcitons
  
  init(on view: UIView) {
    parentView = view
  }
  
  func showSpinner() {
    guard loadingSpinner == nil else {
      return
    }

    let container: UIView = UIView()
    container.frame = parentView.frame
    container.center = parentView.center
    container.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.3)

    let loadingView: UIView = UIView()
    loadingView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
    loadingView.center = parentView.center
    loadingView.backgroundColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.4)
    loadingView.clipsToBounds = true
    loadingView.layer.cornerRadius = 10

    let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
    actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
    actInd.style = UIActivityIndicatorView.Style.large
    actInd.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
    
    loadingView.addSubview(actInd)
    container.addSubview(loadingView)
    parentView.addSubview(container)
    actInd.startAnimating()
    
    loadingSpinner = container
  }
  
  func hideSpinner() {
    loadingSpinner?.removeFromSuperview()
    loadingSpinner = nil
  }
  
}

