//
//  DiscoverMovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol DiscoverMovieFetcher {
  func fetchNowPlaying(page: Int, completion: @escaping (DiscoverMovieResponse?, APIError?) -> Void)
  func fetchLatest(page: Int, completion: @escaping (DiscoverMovieResponse?, APIError?) -> Void)
  func fetchUpcoming(page: Int, completion: @escaping (DiscoverMovieResponse?, APIError?) -> Void)
  func fetchPopular(page: Int, completion: @escaping (DiscoverMovieResponse?, APIError?) -> Void)
  func fetchTopRated(page: Int, completion: @escaping (DiscoverMovieResponse?, APIError?) -> Void)
  func fetchByFilters(genres: String, excludeGenres: String, people: String, companies: String, voteAverage: (Int, Int), minVoteCount: Int, releaseYear: (Int, Int), runtime: (Int, Int), sortBy: String, page: Int, completion: @escaping (DiscoverMovieResponse?, APIError?) -> Void)
  func dismissFetching()
}

struct DiscoverMovieResponse {
  var results: [MovieListItem]
  var page: Int
  var totalPages: Int
}

