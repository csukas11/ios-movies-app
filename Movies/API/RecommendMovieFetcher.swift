//
//  RecommendMovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol RecommendMovieFetcher {
  func fetch(for id: Int, page: Int, completion: @escaping (RecommendedMovieResponse?, APIError?) -> Void)
  func dismissFetching()
}

struct RecommendedMovieResponse {
  var results: [MovieListItem]
  var page: Int
  var totalPages: Int
}
