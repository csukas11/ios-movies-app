//
//  Movie.swift
//  Movies
//
//  Class that holds information on a particular movie.
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

struct Movie {
  var id: Int
  var title: String
  var original_title: String
  var backdrop_url: String?
  var poster_url: String?
  var release_date: String
  var release_year: String {
    get {
      let parts = release_date.components(separatedBy: "-")
      return parts[0]
    }
  }
  var budget: Int?
  var genres: [Genre]
  var runtime: Int?
  var vote_average: Double
  var vote_count: Int
  var overview: String?
  var videos: [Video]
  var images: [Image]
}
