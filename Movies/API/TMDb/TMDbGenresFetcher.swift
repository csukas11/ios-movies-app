//
//  TMDbGenresFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Moya
import Alamofire
import Kingfisher

class TMDbGenresFetcher: GenresFetcher {
  var provider = MoyaProvider<TMDbAPI>() //MoyaProvider<TMDbAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(completion: @escaping (GenresResponse?, APIError?) -> Void) {
    // clear all leftovers
    Alamofire.Session.default.session.invalidateAndCancel()
    
    provider.request(.getGenres) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(Response.self, from: response.data)
          
          var convertedListItems = [GenreListItem]()
          
          for item in results.genres {
            convertedListItems.append(
              GenreListItem(id: item.id,
                            name: item.name)
            )
          }
          
          completion(
            GenresResponse(convertedListItems),
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
  
  func dismissFetching() {
    Alamofire.Session.default.session.invalidateAndCancel()
  }
    
  // MARK: - Support structures
  
  private struct Response: Codable {
    var genres: [APIGenreListItem]
  }
  
  private struct APIGenreListItem: Codable {
    var id: Int
    var name: String
  }
}
