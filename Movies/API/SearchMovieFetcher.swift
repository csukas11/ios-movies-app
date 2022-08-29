//
//  SearchMovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol SearchMovieFetcher {
  func fetch(for keyword: String, page: Int, completion: @escaping (SearchMovieResponse?, APIError?) -> Void)
  func dismissFetching()
}

struct SearchMovieResponse {
  var results: [MovieListItem]
  var page: Int
  var totalPages: Int
}
