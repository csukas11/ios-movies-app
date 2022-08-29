//
//  SwinjectStoryboard+Extension.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Swinject
import SwinjectStoryboard

extension SwinjectStoryboard {
  @objc class func setup() {
    defaultContainer.register(DiscoverMovieFetcher.self) { _ in TMDbDiscoverMovieFetcher() }
    defaultContainer.register(SearchMovieFetcher.self) { _ in TMDbSearchMovieFetcher() }
    defaultContainer.register(SearchPersonFetcher.self) { _ in TMDbSearchPersonFetcher() }
    defaultContainer.register(SearchCompanyFetcher.self) { _ in TMDbSearchCompanyFetcher() }
    defaultContainer.register(GenresFetcher.self) { _ in TMDbGenresFetcher() }
    
    
    defaultContainer.storyboardInitCompleted(DiscoverViewController.self) { resolver, controller in
      controller.discoverMovieFetcher = resolver.resolve(DiscoverMovieFetcher.self)
    }
    
    defaultContainer.storyboardInitCompleted(SearchViewController.self) { resolver, controller in
      controller.searchMovieFetcher = resolver.resolve(SearchMovieFetcher.self)
      controller.searchPersonFetcher = resolver.resolve(SearchPersonFetcher.self)
    }
    
    defaultContainer.storyboardInitCompleted(DiscoverByFilterViewController.self) { resolver, controller in
      controller.genresFetcher = resolver.resolve(GenresFetcher.self)
      controller.searchPersonFetcher = resolver.resolve(SearchPersonFetcher.self)
      controller.searchCompanyFetcher = resolver.resolve(SearchCompanyFetcher.self)
    }
    
    defaultContainer.storyboardInitCompleted(DiscoverByFilterResultsViewController.self) { resolver, controller in
      controller.discoverMovieFetcher = resolver.resolve(DiscoverMovieFetcher.self)
    }
  }
}
