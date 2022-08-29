//
//  TMDbMovieFetcher.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Moya
import Alamofire
import Kingfisher

class TMDbMovieFetcher: MovieFetcher {
  var provider = MoyaProvider<TMDbAPI>() // MoyaProvider<TMDbAPI>(plugins: [NetworkLoggerPlugin()])
  
  func fetch(for id: Int, completion: @escaping (Movie?, APIError?) -> Void) {
    provider.request(.movieDetails(id: id)) { result in
      switch result {
      case let .success(response):
        do {
          let item = try JSONDecoder().decode(APIMovie.self, from: response.data)
          
          var posterURL = ""
          if let poster_path = item.poster_path {
            posterURL = TMDbAPI.imageURL + "/w500" + poster_path
          }
          
          var backdropURL = ""
          if let backdrop_path = item.backdrop_path {
            backdropURL = TMDbAPI.imageURL + "/w780" + backdrop_path
          }
          
          var genres = [Genre]()
          for genre in item.genres {
            genres.append(Genre(id: genre.id, name: genre.name))
          }
          
          var videos = [Video]()
          for video in item.videos.results {
            if video.site == "YouTube" {
              videos.append(Video(name: video.name, site: video.site, key: video.key, url: "https://www.youtube.com/watch?v=\(video.key)"))
            }
          }
          
          var images = [Image]()
          for image in item.images.posters {
            images.append(Image(url: TMDbAPI.imageURL + "/w500" + image.file_path))
          }
          for image in item.images.backdrops {
            images.append(Image(url: TMDbAPI.imageURL + "/w780" + image.file_path))
          }
          
          let movie = Movie(id: item.id,
                            title: item.title,
                            original_title: item.original_title,
                            backdrop_url: backdropURL,
                            poster_url: posterURL,
                            release_date: item.release_date,
                            genres: genres,
                            runtime: item.runtime,
                            vote_average: item.vote_average,
                            vote_count: item.vote_count,
                            overview: item.overview,
                            videos: videos,
                            images: images)
          
          completion(movie, nil)
          
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
  
  func fetchCredits(for id: Int, completion: @escaping (MovieCreditResponse?, APIError?) -> Void) {
    provider.request(.movieCredits(id: id)) { result in
      switch result {
      case let .success(response):
        do {
          let item = try JSONDecoder().decode(Credits.self, from: response.data)
          
          var cast = [Cast]()
          for c in item.cast {
            var profileURL: String?
            if let profile_path = c.profile_path {
              profileURL = TMDbAPI.imageURL + "/w500" + profile_path
            }
            
            cast.append(Cast(id: c.id, name: c.name, character: c.character, profile_url: profileURL))
          }
          
          var crew = [Crew]()
          for c in item.crew {
            var profileURL: String?
            if let profile_path = c.profile_path {
              profileURL = TMDbAPI.imageURL + "/w500" + profile_path
            }
            
            crew.append(Crew(id: c.id, name: c.name, job: c.job, profile_url: profileURL))
          }
          
          completion(
            MovieCreditResponse(cast: cast, crew: crew),
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
  
  func fetchAccountState(for id: Int, completion: @escaping (MovieAccountStateResponse?, APIError?) -> Void) {
    let auth = TMDbAuthenticationFetcher()
    
    if auth.isUserAuthenticated(),
       let sessionId = auth.getSessionId() {
    
      provider.request(.movieAccountState(id: id, sessionId: sessionId)) { result in
        switch result {
        case let .success(response):
          var item: AccountState?
          
          do {
            item = try JSONDecoder().decode(AccountState.self, from: response.data)
          } catch {}
          do {
            let item2 = try JSONDecoder().decode(AccountStateFalse.self, from: response.data)
            item = AccountState(favorite: item2.favorite, watchlist: item2.watchlist, rated: nil)
          } catch let error {
            print(error)
            completion(nil, APIError.UnknownError)
          }
          
          if let item = item {
            var rating: Int?
            if let r = item.rated {
              rating = r.value
            }
            
            completion(
              MovieAccountStateResponse(
                isFavorite: item.favorite,
                isOnWatchlist: item.watchlist,
                rating: rating),
              nil)
          } else {
            completion(nil, APIError.UnknownError)
          }
        case let .failure(error):
          print(error)
          completion(nil, handleTMDbAPIError(error))
        }
      }
    }
  }
  
  func addToWatchlist(id: Int, completion: @escaping (APIError?) -> Void) {
    let auth = TMDbAuthenticationFetcher()
    
    if auth.isUserAuthenticated(),
       let sessionId = auth.getSessionId() {
      
      auth.getUserAccountDetails() { result, error in
        if let account = result {
          self.provider.request(.movieWatchlistStatus(accountId: account.id, movieId: id, value: true, sessionId: sessionId)) { result in
            switch result {
            case .success(_):
              completion(nil)
            case let .failure(error):
              print(error)
              completion(handleTMDbAPIError(error))
            }
          }
        }
      }
    }
  }
  
  func removeFromWatchlist(id: Int, completion: @escaping (APIError?) -> Void) {
    let auth = TMDbAuthenticationFetcher()
    
    if auth.isUserAuthenticated(),
       let sessionId = auth.getSessionId() {
      
      auth.getUserAccountDetails() { result, error in
        if let account = result {
          self.provider.request(.movieWatchlistStatus(accountId: account.id, movieId: id, value: false, sessionId: sessionId)) { result in
            switch result {
            case .success(_):
              completion(nil)
            case let .failure(error):
              print(error)
              completion(handleTMDbAPIError(error))
            }
          }
        }
      }
    }
  }
  
  func rateMovie(id: Int, rating: Int, completion: @escaping (APIError?) -> Void) {
    let auth = TMDbAuthenticationFetcher()
    
    if auth.isUserAuthenticated(),
       let sessionId = auth.getSessionId() {
      
      self.provider.request(.rateMovie(id: id, rating: rating, sessionId: sessionId)) { result in
        switch result {
        case .success(_):
          completion(nil)
        case let .failure(error):
          print(error)
          completion(handleTMDbAPIError(error))
        }
      }
    }
  }
  
  func removeMovieRating(id: Int, completion: @escaping (APIError?) -> Void) {
    let auth = TMDbAuthenticationFetcher()
    
    if auth.isUserAuthenticated(),
       let sessionId = auth.getSessionId() {
      
      self.provider.request(.removeMovieRating(id: id, sessionId: sessionId)) { result in
        switch result {
        case .success(_):
          completion(nil)
        case let .failure(error):
          print(error)
          completion(handleTMDbAPIError(error))
        }
      }
    }
  }
    
  func dismissFetching() {
    Alamofire.Session.default.session.invalidateAndCancel()
  }
}
  
  // MARK: - Support structures
  
  private struct APIGenre: Codable {
    var id: Int
    var name: String
  }

  private struct APIVideo: Codable {
    var key: String
    var name: String
    var site: String
  }

  private struct VideoList: Codable {
    var results: [APIVideo]
  }

  private struct APIImage: Codable {
    var file_path: String
  }

  private struct ImageList: Codable {
    var backdrops: [APIImage]
    var posters: [APIImage]
  }

  private struct APIMovie: Codable {
    var id: Int
    var title: String
    var original_title: String
    var backdrop_path: String?
    var poster_path: String?
    var release_date: String
    var genres: [APIGenre]
    var runtime: Int?
    var vote_average: Double
    var vote_count: Int
    var overview: String?
    var videos: VideoList
    var images: ImageList
  }

  private struct APICast: Codable {
    var id: Int
    var name: String
    var character: String
    var profile_path: String?
  }

  private struct APICrew: Codable {
    var id: Int
    var name: String
    var job: String
    var profile_path: String?
  }

  private struct Credits: Codable {
    var cast: [APICast]
    var crew: [APICrew]
  }

  private struct AccountState: Codable {
    var favorite: Bool
    var watchlist: Bool
    var rated: Rating?
  }

  private struct AccountStateFalse: Codable {
    var favorite: Bool
    var watchlist: Bool
    var rated: Bool
  }

  private struct Rating: Codable {
    var value: Int
  }
