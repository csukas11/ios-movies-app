//
//  WatchlistMovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol WatchlistMovieFetcher {
  func fetch(page: Int, completion: @escaping (WatchlistMovieResponse?, APIError?) -> Void)
  func dismissFetching()
}

struct WatchlistMovieResponse {
  var results: [MovieListItem]
  var page: Int
  var totalPages: Int
}
