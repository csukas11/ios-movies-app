//
//  TMDbSearchCompanyFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Moya
import Alamofire
import Kingfisher

class TMDbSearchCompanyFetcher: SearchCompanyFetcher {
  var provider = MoyaProvider<TMDbAPI>() //MoyaProvider<TMDbAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(for keyword: String, page: Int, completion: @escaping (SearchCompanyResponse?, APIError?) -> Void) {
    // is it a new query? if yes, clear all leftovers
    if page == 1 {
      Alamofire.Session.default.session.invalidateAndCancel()
    }
    
    provider.request(.searchCompanies(keyword: keyword, page: page)) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(SearchResult.self, from: response.data)
          
          var convertedListItems = [CompanyListItem]()
          
          for item in results.results {
            var logoURL = ""
            if let logo_path = item.logo_path {
              logoURL = TMDbAPI.imageURL + "/w500" + logo_path
            }
            
            convertedListItems.append(
              CompanyListItem(id: item.id,
                             name: item.name,
                             logo_url: logoURL)
            )
          }
          
          completion(
            SearchCompanyResponse(results: convertedListItems,
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
    var results: [APICompanyListItem]
  }
  
  private struct APICompanyListItem: Codable {
    var id: Int
    var name: String
    var logo_path: String?
  }
}
