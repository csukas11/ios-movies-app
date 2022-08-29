//
//  PortraitCollectionViewController.swift
//  SnapSoft-Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

class PortraitCollectionViewController: CustomCollectionViewController {
  
  // MARK: - Properties

  // Size of the cells
  override var cellWidth: Double {
    get {
      return Double((UIScreen.main.bounds.size.width - marginLeftRight * 2 - spacing) / 2)
    }
  }
  override var cellHeight: Double {
    get {
      return Double((UIScreen.main.bounds.size.width - marginLeftRight * 2 - spacing) / 2 * (3/2) + 24)
    }
  }
  
}
