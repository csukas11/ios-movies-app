//
//  GenresFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

typealias GenresResponse = [GenreListItem]

protocol GenresFetcher {
  func fetch(completion: @escaping (GenresResponse?, APIError?) -> Void)
  func dismissFetching()
}
