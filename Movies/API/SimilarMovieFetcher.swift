//
//  SimilarMovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol SimilarMovieFetcher {
  func fetch(for id: Int, page: Int, completion: @escaping (SimilarMovieResponse?, APIError?) -> Void)
  func dismissFetching()
}

struct SimilarMovieResponse {
  var results: [MovieListItem]
  var page: Int
  var totalPages: Int
}
