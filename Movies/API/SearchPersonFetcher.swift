//
//  SearchPersonFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol SearchPersonFetcher {
  func fetch(for keyword: String, page: Int, completion: @escaping (SearchPersonResponse?, APIError?) -> Void)
  func dismissFetching()
}

struct SearchPersonResponse {
  var results: [PersonListItem]
  var page: Int
  var totalPages: Int
}
