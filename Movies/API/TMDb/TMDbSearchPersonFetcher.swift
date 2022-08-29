//
//  TMDbSearchPersonFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Moya
import Alamofire
import Kingfisher

class TMDbSearchPersonFetcher: SearchPersonFetcher {
  var provider = MoyaProvider<TMDbAPI>() //MoyaProvider<TMDbAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(for keyword: String, page: Int, completion: @escaping (SearchPersonResponse?, APIError?) -> Void) {
    // is it a new query? if yes, clear all leftovers
    if page == 1 {
      Alamofire.Session.default.session.invalidateAndCancel()
    }
    
    provider.request(.searchPeople(keyword: keyword, page: page)) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(SearchResult.self, from: response.data)
          
          var convertedListItems = [PersonListItem]()
          
          for item in results.results {
            var profileURL = ""
            if let profile_path = item.profile_path {
              profileURL = TMDbAPI.imageURL + "/w500" + profile_path
            }
            
            convertedListItems.append(
              PersonListItem(id: item.id,
                             name: item.name ?? "",
                             known_for_department: item.known_for_department ?? "",
                             profile_url: profileURL)
            )
          }
          
          completion(
            SearchPersonResponse(results: convertedListItems,
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
  
  func dismissFetching() {
    Alamofire.Session.default.session.invalidateAndCancel()
  }
    
  // MARK: - Support structures
  
  private struct SearchResult: Codable {
    var page: Int
    var total_results: Int
    var total_pages: Int
    var results: [APIPersonListItem]
  }
  
  private struct APIPersonListItem: Codable {
    var id: Int
    var name: String?
    var known_for_department: String?
    var profile_path: String?
  }
}
