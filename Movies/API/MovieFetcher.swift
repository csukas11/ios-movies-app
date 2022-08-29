//
//  MovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol MovieFetcher {
  func fetch(for id: Int, completion: @escaping (Movie?, APIError?) -> Void)
  func fetchCredits(for id: Int, completion: @escaping (MovieCreditResponse?, APIError?) -> Void)
  func fetchAccountState(for id: Int, completion: @escaping (MovieAccountStateResponse?, APIError?) -> Void)
  func addToWatchlist(id: Int, completion: @escaping (APIError?) -> Void)
  func removeFromWatchlist(id: Int, completion: @escaping (APIError?) -> Void)
  func rateMovie(id: Int, rating: Int, completion: @escaping (APIError?) -> Void)
  func removeMovieRating(id: Int, completion: @escaping (APIError?) -> Void)
  func dismissFetching()
}

struct MovieCreditResponse {
  var cast: [Cast]
  var crew: [Crew]
}

struct MovieAccountStateResponse {
  var isFavorite: Bool
  var isOnWatchlist: Bool
  var rating: Int?
}
