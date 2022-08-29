//
//  PersonListItem.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

public class PersonListItem {
  public var id = 0
  public var name = ""
  public var known_for_department = ""
  public var profile_url = ""

  init(id: Int = 0,
       name: String = "",
       known_for_department: String = "",
       profile_url: String = "") {
    
    self.id = id
    self.name = name
    self.known_for_department = known_for_department
    self.profile_url = profile_url
  }
}
