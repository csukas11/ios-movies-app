//
//  DiscoverByFilterResultsViewController.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Foundation
import UIKit

extension DiscoverByFilterResultsViewController {
  enum State {
    case loading
    case ready
    case error(String)
  }
}

class DiscoverByFilterResultsViewController: UIViewController {
  
  // The navigatin bar title
  private static let WINDOW_TITLE = "Discover Results"
  // Back button title
  private static let BACK_BUTTON_TITLE = "Discover"
  
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
  var discoverMovieFetcher: DiscoverMovieFetcher?
  
  // Selected movie id
  private var selectedId = 0
  
  // Current discovers's params
  private var currentPage = 0
  private var maxPage = 1

  private var genres = ""
  private var excludeGenres = ""
  private var people = ""
  private var companies = ""
  private var voteAverage = (0, 0)
  private var minVoteCount = 0
  private var releaseYear = (0, 0)
  private var runtime = (0, 0)
  private var sortBy = ""
  
  private var loadingSpinner: LoadingSpinner? = nil
  private var collectionVC: CustomCollectionViewController!
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Navbar title
    navigationItem.title = DiscoverByFilterResultsViewController.WINDOW_TITLE
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .automatic
    
    // Back button
    let backItem = UIBarButtonItem()
    backItem.title = DiscoverByFilterResultsViewController.BACK_BUTTON_TITLE
    navigationItem.backBarButtonItem = backItem
    
    loadingSpinner = LoadingSpinner(on: view)
    state = .loading
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToDiscoverCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self)
        viewController.defaultImage = UIImage(named: "NoPoster") ?? UIImage()
        viewController.defaultImageContentMode = .center
        collectionVC = viewController
        
        loadNextPage(identifier: "")
      }
    } else if segue.identifier == "ToMovieDetails" {
      if let viewController = segue.destination as? MovieViewController {
        viewController.movieID = selectedId
      }
    }
  }
  
  func setFilters(genres: [Int], excludeGenres: [Int], people: [Int], companies: [Int], voteAverage: (Int, Int), minVoteCount: Int, releaseYear: (Int, Int), runtime: (Int, Int), sortBy: String) {
    self.genres = genres.map { String($0) }.joined(separator: ",")
    self.excludeGenres = excludeGenres.map { String($0) }.joined(separator: ",")
    self.people = people.map { String($0) }.joined(separator: ",")
    self.companies = companies.map { String($0) }.joined(separator: ",")
    self.voteAverage = voteAverage
    self.minVoteCount = minVoteCount
    self.releaseYear = releaseYear
    self.runtime = runtime
    self.sortBy = sortBy
  }
  
}

// MARK: - CustomCollectionDelegate

extension DiscoverByFilterResultsViewController: CustomCollectionDelegate {
  
  func loadNextPage(identifier: String) {
    if currentPage < maxPage {
      currentPage += 1
      
      discoverMovieFetcher?.fetchByFilters(genres: genres, excludeGenres: excludeGenres, people: people, companies: companies, voteAverage: voteAverage, minVoteCount: minVoteCount, releaseYear: releaseYear, runtime: runtime, sortBy: sortBy, page: currentPage) { [weak self] response, error in
        guard let self = self else { return }
        
        if let response = response {
          self.maxPage = response.totalPages
          
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
    }
  }
  
  func itemSelected(_ id: Int, identifier: String) {
    selectedId = id
    performSegue(withIdentifier: "ToMovieDetails", sender: self)
  }
  
}
