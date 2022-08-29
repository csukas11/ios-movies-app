//
//  CompanyListItem.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

public class CompanyListItem {
  public var id = 0
  public var name = ""
  public var logo_url = ""

  init(id: Int = 0,
       name: String = "",
       logo_url: String = "") {
    
    self.id = id
    self.name = name
    self.logo_url = logo_url
  }
}
