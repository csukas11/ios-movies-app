//
//  MovieAPI.swift
//  Movies
//
//  Moya Target for TheMovieDatabase.org
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Moya

fileprivate let API_KEY = "d8d567ec45fca8c63bb2a33df382e612"

enum TMDbAPI {
  static var imageURL: String {
    return "https://image.tmdb.org/t/p"
  }
  
  case discoverNowPlaying(page: Int)
  case discoverLatest(page: Int)
  case discoverUpcoming(page: Int)
  case discoverPopular(page: Int)
  case discoverTopRated(page: Int)
  case discoverByFilters(genres: String, excludeGenres: String, people: String, companies: String, voteAverage: (Int, Int), minVoteCount: Int, releaseYear: (Int, Int), runtime: (Int, Int), sortBy: String, page: Int)
  case searchMovies(keyword: String, page: Int)
  case searchPeople(keyword: String, page: Int)
  case searchCompanies(keyword: String, page: Int)
  case getGenres
  case getAuthenticationToken
  case getSessionID(authToken: String)
  case deleteSessionID(sessionId: String)
  case getAccount(sessionId: String)
  case movieDetails(id: Int)
  case movieAccountState(id: Int, sessionId: String)
  case rateMovie(id: Int, rating: Int, sessionId: String)
  case removeMovieRating(id: Int, sessionId: String)
  case movieWatchlistStatus(accountId: Int, movieId: Int, value: Bool, sessionId: String)
  case movieFavoriteStatus(accountId: Int, movieId: Int, value: Bool, sessionId: String)
  case getWatchlist(page: Int, accountId: Int, sessionId: String)
  case movieCredits(id: Int)
  case movieRecommendations(id: Int, page: Int)
  case movieSimilars(id: Int, page: Int)
}

extension TMDbAPI: TargetType {
  var baseURL: URL {
    var url_str = ""
    
    switch self {
      case .discoverNowPlaying(_): fallthrough
      case .discoverLatest(_): fallthrough
      case .discoverUpcoming(_): fallthrough
      case .discoverPopular(_): fallthrough
      case .discoverTopRated(_): fallthrough
      case .discoverByFilters(_, _, _, _, _, _, _, _, _, _): fallthrough
      case .searchMovies(_, _): fallthrough
      case .searchPeople(_, _): fallthrough
      case .searchCompanies(_, _): fallthrough
      case .getGenres: fallthrough
      case .getAuthenticationToken: fallthrough
      case .getSessionID(_): fallthrough
      case .deleteSessionID(_): fallthrough
      case .getAccount(_): fallthrough
      case .movieAccountState(_, _): fallthrough
      case .rateMovie(_, _, _): fallthrough
      case .removeMovieRating(_, _): fallthrough
      case .movieWatchlistStatus(_, _, _, _): fallthrough
      case .movieFavoriteStatus(_, _, _, _): fallthrough
      case .getWatchlist(_, _, _): fallthrough
      case .movieCredits(_): fallthrough
      case .movieRecommendations(_, _): fallthrough
      case .movieSimilars(_, _): fallthrough
      case .movieDetails(_): url_str = "https://api.themoviedb.org/3"
    }
    
    guard let url = URL(string: url_str)  else {
      fatalError("baseURL cannot be configured")
    }
    return url
  }
  
  var path: String {
    switch self {
    case .discoverNowPlaying(_): return "/movie/now_playing"
    case .discoverLatest(_): return "/discover/movie"
    case .discoverUpcoming(_): return "/movie/upcoming"
    case .discoverPopular(_): return "/movie/popular"
    case .discoverTopRated(_): return "/movie/top_rated"
    case .discoverByFilters(_, _, _, _, _, _, _, _, _, _): return "/discover/movie"
    case .searchMovies(_, _): return "/search/movie"
    case .searchPeople(_, _): return "/search/person"
    case .searchCompanies(_, _): return "/search/company"
    case .getGenres: return "/genre/movie/list"
    case .getAuthenticationToken: return "/authentication/token/new"
    case .getSessionID(_): return "/authentication/session/new"
    case .deleteSessionID(_): return "/authentication/session"
    case .getAccount(_): return "/account"
    case .movieAccountState(let id, _): return "/movie/\(id)/account_states"
    case .movieCredits(let id): return "/movie/\(id)/credits"
    case .movieRecommendations(let id, _): return "/movie/\(id)/recommendations"
    case .movieSimilars(let id, _): return "/movie/\(id)/similar"
    case .movieDetails(let id): return "/movie/\(id)"
    case .rateMovie(let movieId, _, _): return "/movie/\(movieId)/rating"
    case .removeMovieRating(let movieId, _): return "/movie/\(movieId)/rating"
    case .movieWatchlistStatus(let accountId, _, _, _): return "/account/\(accountId)/watchlist"
    case .movieFavoriteStatus(let accountId, _, _, _): return "/account/\(accountId)/favorite"
    case .getWatchlist(_, let accountId, _): return "/account/\(accountId)/watchlist/movies"
    }
  }
  
  var method: Method {
    switch self {
    case .discoverNowPlaying(_): fallthrough
    case .discoverLatest(_): fallthrough
    case .discoverUpcoming(_): fallthrough
    case .discoverPopular(_): fallthrough
    case .discoverTopRated(_): fallthrough
    case .discoverByFilters(_, _, _, _, _, _, _, _, _, _): fallthrough
    case .searchMovies(_, _): fallthrough
    case .searchPeople(_, _): fallthrough
    case .searchCompanies(_, _): fallthrough
    case .getGenres: fallthrough
    case .getAuthenticationToken: fallthrough
    case .getAccount(_): fallthrough
    case .movieAccountState(_, _): fallthrough
    case .getWatchlist(_, _, _): fallthrough
    case .movieCredits(_): fallthrough
    case .movieRecommendations(_, _): fallthrough
    case .movieSimilars(_, _): fallthrough
    case .movieDetails(_): return .get
    case .rateMovie(_, _, _): fallthrough
    case .movieWatchlistStatus(_, _, _, _): fallthrough
    case .movieFavoriteStatus(_, _, _, _): fallthrough
    case .getSessionID(_): return .post
    case .deleteSessionID(_): fallthrough
    case .removeMovieRating(_, _): return .delete
    }
  }
  
  var sampleData: Data {
    return Data()
  }
  
  var task: Task {
    let commonParams: Dictionary<String, String> = [
      "api_key": API_KEY,
      "language": Locale.preferredLanguages[0],
      "region": Locale.current.regionCode ?? "",
      "include_image_language": "\(Locale.preferredLanguages[0]),en,null"
    ]
    
    switch self {
    case .discoverLatest(let page):
      let date = Date()
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"

      var params = [
        "primary_release_date.lte": formatter.string(from: date),
        "vote_count.gte": "10",
        "sort_by": "primary_release_date.desc",
        "page": "\(page)"
      ]
      params.merge(commonParams) { (current, _) in current }
      
      return .requestParameters(
        parameters: params,
        encoding: URLEncoding.default
      )
      
      case .discoverNowPlaying(let page): fallthrough
      case .discoverUpcoming(let page): fallthrough
      case .discoverPopular(let page): fallthrough
      case .discoverTopRated(let page):
        var params = [
          "page": "\(page)"
        ]
        params.merge(commonParams) { (current, _) in current }
        
        return .requestParameters(
          parameters: params,
          encoding: URLEncoding.default
        )
        
    case .discoverByFilters(let genres, let excludeGenres, let people, let companies, let voteAverage, let minVoteCount, let releaseYear, let runtime, let sortBy, let page):
        var params = [
          "page": "\(page)",
          "with_genres": "\(genres)",
          "without_genres": "\(excludeGenres)",
          "with_people": "\(people)",
          "with_companies": "\(companies)",
          "vote_average.gte": "\(voteAverage.0)",
          "vote_average.lte": "\(voteAverage.1)",
          "vote_count.gte": "\(minVoteCount)",
          "primary_release_date.gte": "\(releaseYear.0)-01-01",
          "primary_release_date.lte": "\(releaseYear.1)-12-31",
          "with_runtime.gte": "\(runtime.0)",
          "with_runtime.lte": "\(runtime.1)",
          "sort_by": "\(sortBy)"
        ]
        params.merge(commonParams) { (current, _) in current }
        
        return .requestParameters(
          parameters: params,
          encoding: URLEncoding.default
        )
    
    
      case .searchMovies(let keyword, let page): fallthrough
      case .searchPeople(let keyword, let page): fallthrough
      case .searchCompanies(let keyword, let page):
        var params = [
          "query": keyword,
          "page": "\(page)"
        ]
        params.merge(commonParams) { (current, _) in current }
      
        return .requestParameters(
          parameters: params,
          encoding: URLEncoding.default
        )
        
      case .movieDetails(_):
        var params = [
          "append_to_response": "genres,videos,images",
          "include_image_language": "en,null"
        ]
        params.merge(commonParams) { (current, _) in current }
        
        return .requestParameters(
          parameters: params,
          encoding: URLEncoding.default
        )
        
      case .movieAccountState(_, let sessionId):
        var params = [
          "session_id": sessionId
        ]
        params.merge(commonParams) { (current, _) in current }
        
        return .requestParameters(
          parameters: params,
          encoding: URLEncoding.default
        )
        
      case .movieCredits(_):
        return .requestParameters(
          parameters: commonParams,
          encoding: URLEncoding.default
        )
        
      case .movieRecommendations(_, let page):
        var params = [
          "page": "\(page)"
        ]
        params.merge(commonParams) { (current, _) in current }
        
        return .requestParameters(
          parameters: params,
          encoding: URLEncoding.default
        )
        
      case .movieSimilars(_, let page):
        var params = [
          "page": "\(page)"
        ]
        params.merge(commonParams) { (current, _) in current }
        
        return .requestParameters(
          parameters: params,
          encoding: URLEncoding.default
        )
        
      case .getGenres:
        return .requestParameters(
          parameters: commonParams,
          encoding: URLEncoding.default
        )
        
      case .getAuthenticationToken:
        return .requestParameters(
          parameters: ["api_key": API_KEY],
          encoding: URLEncoding.default
        )
        
      case .getSessionID(let authToken):
        return .requestCompositeParameters(bodyParameters: [
                                             "request_token": authToken
                                           ],
                                           bodyEncoding: JSONEncoding.default,
                                           urlParameters: [
                                             "api_key": API_KEY
                                          ])
        
    case .deleteSessionID(let sessionId):
      return .requestCompositeParameters(bodyParameters: [
                                           "session_id": sessionId
                                         ],
                                         bodyEncoding: JSONEncoding.default,
                                         urlParameters: [
                                           "api_key": API_KEY
                                        ])
        
    case .getAccount(let sessionId):
      return .requestParameters(
        parameters: [
          "api_key": API_KEY,
          "session_id": sessionId
        ],
        encoding: URLEncoding.default
      )
      
    case .rateMovie(_, let rating, let sessionId):
        return .requestCompositeParameters(bodyParameters: [
                                            "value": rating
                                           ],
                                           bodyEncoding: JSONEncoding.default,
                                           urlParameters: [
                                            "api_key": API_KEY,
                                            "session_id": sessionId
                                          ])
      
    case .removeMovieRating(_, let sessionId):
      return .requestParameters(
        parameters: [
          "api_key": API_KEY,
          "session_id": sessionId
        ],
        encoding: URLEncoding.default
      )
      
    case .movieWatchlistStatus(_, let movieId, let value, let sessionId):
      return .requestCompositeParameters(bodyParameters: [
                                          "media_type": "movie",
                                          "media_id": movieId,
                                          "watchlist": value
                                         ],
                                         bodyEncoding: JSONEncoding.default,
                                         urlParameters: [
                                          "api_key": API_KEY,
                                          "session_id": sessionId
                                        ])
      
    case .movieFavoriteStatus(_, let movieId, let value, let sessionId):
      return .requestCompositeParameters(bodyParameters: [
                                          "media_type": "movie",
                                          "media_id": movieId,
                                          "favorite": value
                                         ],
                                         bodyEncoding: JSONEncoding.default,
                                         urlParameters: [
                                          "api_key": API_KEY,
                                          "session_id": sessionId
                                        ])
      
    case .getWatchlist(let page, _, let sessionId):
      var params = [
        "page": "\(page)",
        "session_id": sessionId
      ]
      params.merge(commonParams) { (current, _) in current }
      
      return .requestParameters(
        parameters: params,
        encoding: URLEncoding.default
      )
      
    }
  }
  
  var headers: [String : String]? {
    return ["Content-Type": "application/json"]
  }
  
  public var validationType: ValidationType {
    return .successCodes
  }
}

// MARK: - HandleAPIError
func handleTMDbAPIError(_ error: MoyaError) -> APIError {
  switch error {
  case .statusCode(let response):
    switch response.statusCode {
    case 401:
      return APIError.AuthenticationFail
    default:
      return APIError.UnknownError
    }
    
  case .underlying(let nsError as NSError, _):
    switch nsError.code {
    case NSURLErrorTimedOut:
      return APIError.ResponseTimeOut
    case NSURLErrorNotConnectedToInternet:
      return APIError.NoInternetConnection
    default:
      return APIError.UnknownError
    }
  default:
    return APIError.UnknownError
  }
}
