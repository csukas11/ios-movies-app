//
//  APIError.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

enum APIError {
  case UnknownError
  case NoInternetConnection
  case AuthenticationFail
  case ResponseTimeOut
  
  var errorMsg: String {
      switch self {
      case .NoInternetConnection:
        return "There is no internet connection!"
      
      case .AuthenticationFail:
        return "There was a problem during authentication."
      
      case .ResponseTimeOut:
        return "Network connection time out."
      case .UnknownError:
        return ""
      }
   }
}
