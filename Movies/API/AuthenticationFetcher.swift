//
//  AuthenticationFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

protocol AuthenticationFetcher {
  func authenticate(completion: @escaping (String?, APIError?) -> Void)
  func terminateSession(completion: ((APIError?) -> Void)?)
  func updateAuthenticationState(completion: ((APIError?) -> Void)?)
  func isUserAuthenticated() -> Bool
  func getUserAccountDetails(completion: @escaping (UserAccountResponse?, APIError?) -> Void)
}

struct UserAccountResponse {
  var id: Int
  var username: String
}
