//
//  GenreListItem.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

public class GenreListItem {
  public var id = 0
  public var name = ""

  init(id: Int = 0,
       name: String = "") {
    
    self.id = id
    self.name = name
  }
}
