//
//  TMDbWatchlistMovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Moya
import Alamofire
import Kingfisher

class TMDbWatchlistMovieFetcher: WatchlistMovieFetcher {
  var provider = MoyaProvider<TMDbAPI>() //MoyaProvider<TMDbAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(page: Int, completion: @escaping (WatchlistMovieResponse?, APIError?) -> Void) {
    // is it a new query? if yes, clear all leftovers
    if page == 1 {
      Alamofire.Session.default.session.invalidateAndCancel()
    }
      
    let auth = TMDbAuthenticationFetcher()
      
    if auth.isUserAuthenticated(),
       let sessionId = auth.getSessionId() {
        
        auth.getUserAccountDetails() { result, error in
          if let account = result {
            self.provider.request(.getWatchlist(page: page, accountId: account.id, sessionId: sessionId)) { result in
              switch result {
              case let .success(response):
                do {
                  let results = try JSONDecoder().decode(SearchResult.self, from: response.data)
                  
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
                    WatchlistMovieResponse(results: convertedListItems,
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
          }
        }
      }
  }
  
  func dismissFetching() {
    Alamofire.Session.default.session.invalidateAndCancel()
  }
    
  // MARK: - Support structures
  
  private struct SearchResult: Codable {
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
