//
//  MovieListCollectionViewController.swift
//  Movies
//
//  ViewController responsible for loading movies using the API.
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Foundation
import UIKit

extension SearchViewController {
  enum State {
    case loading
    case ready
    case error(String)
  }
}

class SearchViewController: SearchBarViewController {
  
  // The navigatin bar title
  private static let WINDOW_TITLE = "Search"
  // Back button title
  private static let BACK_BUTTON_TITLE = "Search"
  // Placeholder for the search bar
  private static let SEARCH_PLACEHOLDER = "Search Movies or People"
  
  ///------------------------------------------------------------------
  
  // MARK: - Properties
  
  // View State
  private var state: State = .ready {
    didSet {
      switch state {
      case .ready:
        loadingSpinner?.hideSpinner()
      case .loading:
        loadingSpinner?.showSpinner()
      case .error(let msg):
        loadingSpinner?.hideSpinner()
        print(msg)
      }
    }
  }
  
  // Fetchers
  var searchMovieFetcher: SearchMovieFetcher?
  var searchPersonFetcher: SearchPersonFetcher?
  
  // Current search's params
  private var searchScope: Int = 0 { // 0: movies, 1: people
    didSet {
      // Change default image
      if searchScope == 0 {
        collectionVC.defaultImage = UIImage(named: "NoPoster") ?? UIImage()
      } else {
        collectionVC.defaultImage = UIImage(named: "NoProfile") ?? UIImage()
      }
    }
  }
  private var searchCurrentKeyword: String? = nil
  private var searchCurrentPage = 0
  private var searchMaxPage = 1
  
  // Selected item details
  private var selectedId = 0
  
  // UI elements
  private var collectionVC: CustomCollectionViewController!
  private var loadingSpinner: LoadingSpinner? = nil
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    hideKeyboardWhenTappedAround()
    
    // Nav title
    navItemTitle = SearchViewController.WINDOW_TITLE
    searchPlaceholder = SearchViewController.SEARCH_PLACEHOLDER
    
    // Back button
    let backItem = UIBarButtonItem()
    backItem.title = SearchViewController.BACK_BUTTON_TITLE
    navigationItem.backBarButtonItem = backItem
    
    // Set scope selection
    searchController.searchBar.showsScopeBar = true
    searchController.searchBar.scopeButtonTitles = ["Movies", "People"]
    
    loadingSpinner = LoadingSpinner(on: view)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToPortraitCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        collectionVC = viewController
        collectionVC.setDelegate(self, identifier: "Search")
        collectionVC.scrollDirection = .vertical
        collectionVC.defaultImage = UIImage(named: "NoPoster") ?? UIImage()
        collectionVC.defaultImageContentMode = .center
      }
    } else if segue.identifier == "ToMovieDetails" {
      if let viewController = segue.destination as? MovieViewController {
        viewController.movieID = selectedId
      }
    }
  }
  
  // MARK: - Search
  
  // Perform the search with the given keyword
  override func search(for keyword: String) {
    searchCurrentKeyword = keyword
    
    // Reset search params
    searchCurrentPage = 0
    searchMaxPage = 1
    
    // Cancel ongoing search
    searchMovieFetcher?.dismissFetching()
    searchPersonFetcher?.dismissFetching()
    if keyword.isEmpty { return }
    collectionVC.clearItems()
    
    // Load results
    state = .loading
    loadNextPage(identifier: "")
  }
  
  // Cancel the current search
  override func dismissSearch() {
    // Reset search params
    searchCurrentPage = 0
    searchMaxPage = 1
    searchCurrentKeyword = ""
    
    // Cancel ongoing search
    searchMovieFetcher?.dismissFetching()
    searchPersonFetcher?.dismissFetching()
    collectionVC.clearItems()
  }

}

// MARK: - UISearchBarDelegate
  
extension SearchViewController {
  func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
    searchScope = selectedScope
    
    // Perform new search
    if let searchKeyword = searchCurrentKeyword, !searchKeyword.isEmpty {
      search(for: searchKeyword)
    } else {
      dismissSearch()
    }
  }
}

// MARK: - CustomCollectionDelegate

extension SearchViewController: CustomCollectionDelegate {
  func loadNextPage(identifier: String) {
    if let searchKeyword = searchCurrentKeyword, !searchKeyword.isEmpty, searchCurrentPage < searchMaxPage {
      searchCurrentPage += 1
      
      if self.searchScope == 0 {
        searchMovieFetcher?.fetch(for: searchKeyword, page: searchCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.searchMaxPage = response.totalPages
            
            for item in response.results {
              self.collectionVC.addItem(
                CustomCollectionViewController.ListItem(id: item.id,
                                         title: item.title,
                                         subtitle: item.release_year,
                                         badge: (item.rating > 0.0 ? String(item.rating) : ""),
                                         badgeColor: MovieListItem.getBadgeColor(for: item.rating),
                                         imageURL: item.poster_url)
              )
            }
            
            if response.page == 1 {
              self.state = .ready
            }
          }
        }
      } else {
        searchPersonFetcher?.fetch(for: searchKeyword, page: searchCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.searchMaxPage = response.totalPages
            
            for item in response.results {
              self.collectionVC.addItem(
                CustomCollectionViewController.ListItem(id: item.id,
                                         title: item.name,
                                         subtitle: item.known_for_department,
                                         imageURL: item.profile_url)
              )
            }
            
            if response.page == 1 {
              self.state = .ready
            }
          }
        }
      }
    }
  }
  
  func itemSelected(_ id: Int, identifier: String) {
    selectedId = id
    
    if searchScope == 0 {
      performSegue(withIdentifier: "ToMovieDetails", sender: self)
    } else {
      guard let urlObj = URL(string: "https://www.themoviedb.org/person/\(id)") else { return }
      
      UIApplication.shared.open(urlObj)
    }
    return
  }
  
}

