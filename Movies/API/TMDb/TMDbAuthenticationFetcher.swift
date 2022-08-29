//
//  TMDbAuthenticationFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Moya
import Alamofire
import Kingfisher
import KeychainAccess

class TMDbAuthenticationFetcher: AuthenticationFetcher {
  var provider = MoyaProvider<TMDbAPI>() //MoyaProvider<TMDbAPI>(plugins: [NetworkLoggerPlugin()])
  
  func authenticate(completion: @escaping (String?, APIError?) -> Void) {
    let authState = UserDefaults.standard.integer(forKey: "auth_state")
    if authState == 0 {
      provider.request(.getAuthenticationToken) { result in
        switch result {
        case let .success(response):
          do {
            let results = try JSONDecoder().decode(TokenResponse.self, from: response.data)
            
            guard let success = results.success,
                  let expires_at = results.expires_at,
                  let request_token = results.request_token,
                  success else { return }
              
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "UTC")
            dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss' UTC'"
            
            let date = dateFormatter.date(from: expires_at)
            guard let timezone = TimeZone(identifier: "UTC") else { return }
            guard let localDate = date?.convertToTimeZone(initTimeZone: timezone, timeZone: TimeZone.current) else { return }
            
            let dateFormatter2 = DateFormatter()
            dateFormatter2.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
            
            let localDateString = dateFormatter2.string(from: localDate)
            
            let keychain = Keychain(service: "org.csukas.Movies")
            keychain["auth_token"] = request_token
            UserDefaults.standard.set(localDateString, forKey: "request_token_expires_at")
            UserDefaults.standard.set(1, forKey: "auth_state")
            
            completion("https://www.themoviedb.org/authenticate/\(request_token)", nil)
          } catch let error {
            print(error)
            completion(nil, APIError.UnknownError)
          }
        case let .failure(error):
          print(error)
          completion(nil, handleTMDbAPIError(error))
        }
      }
    } else if authState == 1 {
      let authExpStr = UserDefaults.standard.string(forKey: "request_token_expires_at")
      guard let authExp = authExpStr,
            !authExp.isEmpty else {
        
        UserDefaults.standard.set(0, forKey: "auth_state")
        return
      }
      
      let keychain = Keychain(service: "org.csukas.Movies")
      let authTokenStr = keychain["auth_token"]
      
      guard let authToken = authTokenStr,
            !authToken.isEmpty else {
        
        UserDefaults.standard.set(0, forKey: "auth_state")
        return
      }
      
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
      guard let date = dateFormatter.date(from: authExp) else { return }
      
      guard date > Date() else {
        keychain["auth_token"] = ""
        UserDefaults.standard.set("", forKey: "request_token_expires_at")
        UserDefaults.standard.set(0, forKey: "auth_state")
        return
      }
      
      completion("https://www.themoviedb.org/authenticate/\(authToken)", nil)
    }
  }
  
  func terminateSession(completion: ((APIError?) -> Void)?) {
    let keychain = Keychain(service: "org.csukas.Movies")
    
    if isUserAuthenticated(),
       let sessionId = keychain["session_id"] {
      provider.request(.deleteSessionID(sessionId: sessionId)) { result in
        switch result {
        case .success(_):
          completion?(nil)
        case let .failure(error):
          print(error)
          completion?(handleTMDbAPIError(error))
        }
      }
    }
    
    UserDefaults.standard.set(0, forKey: "auth_state")
    keychain["session_id"] = ""
  }
  
  func updateAuthenticationState(completion: ((APIError?) -> Void)?) {
    let authState = UserDefaults.standard.integer(forKey: "auth_state")
    if authState == 0 || authState == 2 { return }
    
    let authExpStr = UserDefaults.standard.string(forKey: "request_token_expires_at")
    guard let authExp = authExpStr,
          !authExp.isEmpty else {
      
      UserDefaults.standard.set(0, forKey: "auth_state")
      return
    }
    
    let keychain = Keychain(service: "org.csukas.Movies")
    let authTokenStr = keychain["auth_token"]
    
    guard let authToken = authTokenStr,
          !authToken.isEmpty else {
      
      UserDefaults.standard.set(0, forKey: "auth_state")
      return
    }
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
    guard let date = dateFormatter.date(from: authExp) else { return }
    
    guard date > Date() else {
      keychain["auth_token"] = ""
      UserDefaults.standard.set("", forKey: "request_token_expires_at")
      UserDefaults.standard.set(0, forKey: "auth_state")
      return
    }
    
    provider.request(.getSessionID(authToken: authToken)) { result in
      switch result {
      case let .success(response):
        do {
          let results = try JSONDecoder().decode(SessionIDResponse.self, from: response.data)
          
          if let success = results.success,
             let session_id = results.session_id,
             success {
            
            keychain["auth_token"] = ""
            keychain["session_id"] = session_id
            UserDefaults.standard.set("", forKey: "request_token_expires_at")
            UserDefaults.standard.set(2, forKey: "auth_state")
            
            completion?(nil)
          }
        } catch let error {
          print(error)
          completion?(APIError.UnknownError)
        }
      case let .failure(error):
        print(error)
        completion?(handleTMDbAPIError(error))
      }
    }
    
    // check if we got auth token
    // is it valid for now?
    // if yes, try to get session_id
    // if it fails, update state
  }
  
  func isUserAuthenticated() -> Bool {
    return UserDefaults.standard.integer(forKey: "auth_state") == 2
  }
  
  func getSessionId() -> String? {
    let keychain = Keychain(service: "org.csukas.Movies")
    return keychain["session_id"]
  }
  
  func getUserAccountDetails(completion: @escaping (UserAccountResponse?, APIError?) -> Void) {
    if isUserAuthenticated(),
       let sessionId = getSessionId() {
    
      provider.request(.getAccount(sessionId: sessionId)) { result in
        switch result {
        case let .success(response):
          do {
            let item = try JSONDecoder().decode(Account.self, from: response.data)
            
            completion(
              UserAccountResponse(
                id: item.id,
                username: item.username
              ),
              nil)
            
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
    
  // MARK: - Support structures
  
  private struct TokenResponse: Codable {
    var success: Bool?
    var expires_at: String?
    var request_token: String?
  }
  
  private struct SessionIDResponse: Codable {
    var success: Bool?
    var session_id: String?
    var failure: Bool?
    var status_code: Int?
    var status_message: String?
  }
  
  private struct Account: Codable {
    var id: Int
    var username: String
  }
}

// For timezone conversation
extension Date {
    func convertToTimeZone(initTimeZone: TimeZone, timeZone: TimeZone) -> Date {
         let delta = TimeInterval(timeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
         return addingTimeInterval(delta)
    }
}
