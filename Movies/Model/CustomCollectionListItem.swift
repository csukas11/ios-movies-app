//
//  CollectionViewListItem.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

class CollectionListItem {
  var title: String
  var subtitle: String
  var badge: String
  var badgeColor: UIColor
  var imageURL: String
  
  init(title: String = "", subtitle: String = "", badge: String = "", badgeColor: UIColor, imageURL: String = "") {
    self.title = title
    self.subtitle = subtitle
    self.badge = badge
    self.badgeColor = badgeColor
    self.imageURL = imageURL
  }
}
