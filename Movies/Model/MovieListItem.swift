//
//  Movie.swift
//  Movies
//
//  Class that holds information on a particular movie.
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

public class MovieListItem {
  public var id = 0
  public var title = ""
  public var release_year = ""
  public var rating = 0.0
  public var user_rating = 0.0
  public var genres = [Genre]()
  public var poster_url = ""
  public var backdrop_url = ""

  init(id: Int = 0,
       title: String = "",
       release_year: String = "",
       rating: Double = 0.0,
       user_rating: Double = 0.0,
       genres: [Genre] = [],
       poster_url: String = "",
       backdrop_url: String = "") {
    
    self.id = id
    self.title = title
    self.release_year = release_year
    self.rating = round(rating * 10.0) / 10.0
    self.user_rating = user_rating
    self.genres = genres
    self.poster_url = poster_url
    self.backdrop_url = backdrop_url
  }
  
  static func getBadgeColor(for rating: Double) -> UIColor {
    var color = UIColor.black
    
    switch rating {
      case 0.1..<5.0:
        color = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
      case 5.0..<8.0:
        color = UIColor(displayP3Red: 0.80, green: 0.56, blue: 0.0, alpha: 1.0)
      case 8.0..<10.1:
        color = UIColor(displayP3Red: 0.0, green: 0.75, blue: 0.13, alpha: 1.0)
      default:
        color = UIColor.gray
    }
    
    return color
  }
}
