//
//  LandscapeCollectionViewController.swift
//  SnapSoft-Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

class LandscapeCollectionViewController: CustomCollectionViewController {
  
  // MARK: - Properties
  
  // Size of the cells
  override var cellWidth: Double {
    get {
      // UIScreen.main.bounds.size.width
      // collectionView.bounds.width
      // let guide = view.safeAreaLayoutGuide
      // let layoutWidth = guide.layoutFrame.size.width
      
      return Double(UIScreen.main.bounds.size.width - marginLeftRight * 2)
    }
  }
  override var cellHeight: Double {
    get {
      return Double((UIScreen.main.bounds.size.width - marginLeftRight * 2) * (9/16) + 24)
    }
  }
  
}
