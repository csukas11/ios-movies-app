//
//  SearchCompanyFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol SearchCompanyFetcher {
  func fetch(for keyword: String, page: Int, completion: @escaping (SearchCompanyResponse?, APIError?) -> Void)
  func dismissFetching()
}

struct SearchCompanyResponse {
  var results: [CompanyListItem]
  var page: Int
  var totalPages: Int
}
