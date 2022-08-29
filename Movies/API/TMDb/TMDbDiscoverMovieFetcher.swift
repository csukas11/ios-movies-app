//
//  TMDbDiscoverMovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Moya
import Alamofire
import Kingfisher

class TMDbDiscoverMovieFetcher: DiscoverMovieFetcher {
  
  typealias CompletionHandler = (DiscoverMovieResponse?, APIError?) -> Void
  
  var provider = MoyaProvider<TMDbAPI>() // MoyaProvider<TMDbAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetchNowPlaying(page: Int, completion: @escaping CompletionHandler) {
    provider.request(.discoverNowPlaying(page: page)) { result in
      self.processResult(result: result, completion: completion)
    }
  }
  
  func fetchLatest(page: Int, completion: @escaping CompletionHandler) {
    provider.request(.discoverLatest(page: page)) { result in
      self.processResult(result: result, completion: completion)
    }
  }
  
  func fetchUpcoming(page: Int, completion: @escaping CompletionHandler) {
    provider.request(.discoverUpcoming(page: page)) { result in
      self.processResult(result: result, completion: completion)
    }
  }
  
  func fetchPopular(page: Int, completion: @escaping CompletionHandler) {
    provider.request(.discoverPopular(page: page)) { result in
      self.processResult(result: result, completion: completion)
    }
  }
  
  func fetchTopRated(page: Int, completion: @escaping CompletionHandler) {
    provider.request(.discoverTopRated(page: page)) { result in
      self.processResult(result: result, completion: completion)
    }
  }
  
  func fetchByFilters(genres: String, excludeGenres: String, people: String, companies: String, voteAverage: (Int, Int), minVoteCount: Int, releaseYear: (Int, Int), runtime: (Int, Int), sortBy: String, page: Int, completion: @escaping (DiscoverMovieResponse?, APIError?) -> Void) {
    provider.request(.discoverByFilters(genres: genres, excludeGenres: excludeGenres, people: people, companies: companies, voteAverage: voteAverage, minVoteCount: minVoteCount, releaseYear: releaseYear, runtime: runtime, sortBy: sortBy, page: page)) { result in
      self.processResult(result: result, completion: completion)
    }
  }
  
  func processResult(result: Result<Moya.Response, MoyaError>, completion: CompletionHandler) {
    switch result {
    case let .success(response):
      do {
        let results = try JSONDecoder().decode(DiscoverResult.self, from: response.data)
        
        var convertedListItems = [MovieListItem]()
        
        for item in results.results {
          var release_year = ""
          if let release_date = item.release_date {
            let parts = release_date.components(separatedBy: "-")
            release_year = parts[0]
          }
          
          var posterURL = ""
          if let poster_path = item.poster_path {
            posterURL = TMDbAPI.imageURL + "/w500" + poster_path
          }
          
          var backdropURL = ""
          if let backdrop_path = item.backdrop_path {
            backdropURL = TMDbAPI.imageURL + "/w780" + backdrop_path
          }
          
          convertedListItems.append(
            MovieListItem(id: item.id,
                          title: item.title ?? item.original_title ?? "",
                          release_year: release_year,
                          rating: item.vote_average ?? 0.0,
                          poster_url: posterURL,
                          backdrop_url: backdropURL)
          )
        }
        
        completion(
          DiscoverMovieResponse(results: convertedListItems,
                              page: results.page,
                              totalPages: results.total_pages),
          nil
        )
        
      } catch let error {
        print(error)
        completion(nil, APIError.UnknownError)
      }
    case let .failure(error):
      print(error)
      completion(nil, handleTMDbAPIError(error))
    }
  }
  
  func dismissFetching() {
    Alamofire.Session.default.session.invalidateAndCancel()
  }
    
  // MARK: - Support structures
  
  private struct DiscoverResult: Codable {
    var page: Int
    var total_results: Int
    var total_pages: Int
    var results: [APIMovieListItem]
  }
  
  private struct APIMovieListItem: Codable {
    var id: Int
    var title: String?
    var release_date: String?
    var vote_average: Double?
    var original_title: String?
    var poster_path: String?
    var backdrop_path: String?
  }
}
