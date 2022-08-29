//
//  DiscoverViewController.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {
  
  // Navigatin bar title
  private static let WINDOW_TITLE = "Discover"
  // Back button title
  private static let BACK_BUTTON_TITLE = "Discover"
  
  ///------------------------------------------------------------------
  
  // IBOutlets
  @IBOutlet weak var filtersButton: UIButton!
  
  @IBOutlet weak var nowPlayingContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var latestContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var upcomingContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var popularContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var topRatedContainerHeight: NSLayoutConstraint!
  
  // MARK: - Properties
  
  // Fetchers
  var discoverMovieFetcher: DiscoverMovieFetcher?
  
  // Selected movie id
  private var selectedId = 0
  
  // Now Playing
  private var nowPlayingCurrentPage = 0
  private var nowPlayingMaxPage = 1
  private var nowPlayingCollectionVC: CustomCollectionViewController!
  // Latest
  private var latestCurrentPage = 0
  private var latestMaxPage = 1
  private var latestCollectionVC: CustomCollectionViewController!
  // Upcoming
  private var upcomingCurrentPage = 0
  private var upcomingMaxPage = 1
  private var upcomingCollectionVC: CustomCollectionViewController!
  // Popular
  private var popularCurrentPage = 0
  private var popularMaxPage = 1
  private var popularCollectionVC: CustomCollectionViewController!
  // Top Rated
  private var topRatedCurrentPage = 0
  private var topRatedMaxPage = 1
  private var topRatedCollectionVC: CustomCollectionViewController!
  
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set scope selection
    
    // Navbar title
    navigationItem.title = DiscoverViewController.WINDOW_TITLE
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .automatic
    
    // Back button
    let backItem = UIBarButtonItem()
    backItem.title = DiscoverViewController.BACK_BUTTON_TITLE
    navigationItem.backBarButtonItem = backItem
    
    // UI resizing
    // DiscoverByFiler button
    filtersButton.layer.cornerRadius = 6.0
    filtersButton.clipsToBounds = true
    // CollectionView heights
    nowPlayingContainerHeight.constant = CGFloat(nowPlayingCollectionVC.cellHeight)
    latestContainerHeight.constant = CGFloat(latestCollectionVC.cellHeight)
    upcomingContainerHeight.constant = CGFloat(upcomingCollectionVC.cellHeight)
    popularContainerHeight.constant = CGFloat(popularCollectionVC.cellHeight)
    topRatedContainerHeight.constant = CGFloat(topRatedCollectionVC.cellHeight)
    view.layoutIfNeeded()
    
    loadNextPage(identifier: "NowPlaying")
    loadNextPage(identifier: "Latest")
    loadNextPage(identifier: "Upcoming")
    loadNextPage(identifier: "Popular")
    loadNextPage(identifier: "TopRated")
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToNowPlayingCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "NowPlaying")
        setCollectionViewController(viewController)
        nowPlayingCollectionVC = viewController
      }
    } else if segue.identifier == "ToLatestCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "Latest")
        setCollectionViewController(viewController)
        latestCollectionVC = viewController
      }
    } else if segue.identifier == "ToUpcomingCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "Upcoming")
        setCollectionViewController(viewController)
        upcomingCollectionVC = viewController
      }
    } else if segue.identifier == "ToPopularCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "Popular")
        setCollectionViewController(viewController)
        popularCollectionVC = viewController
      }
    } else if segue.identifier == "ToTopRatedCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "TopRated")
        setCollectionViewController(viewController)
        topRatedCollectionVC = viewController
      }
    } else if segue.identifier == "ToMovieDetails" {
      if let viewController = segue.destination as? MovieViewController {
        viewController.movieID = selectedId
      }
    }
  }
  
  private func setCollectionViewController(_ cv: CustomCollectionViewController) {
    cv.scrollDirection = .horizontal
    cv.defaultImage = UIImage(named: "NoPoster") ?? UIImage()
    cv.defaultImageContentMode = .center
  }
}
  
// MARK: - CustomCollectionDelegate
  
extension DiscoverViewController: CustomCollectionDelegate {
  func loadNextPage(identifier: String) {
    if identifier == "NowPlaying" {
      if nowPlayingCurrentPage < nowPlayingMaxPage {
        nowPlayingCurrentPage += 1
        
        discoverMovieFetcher?.fetchNowPlaying(page: nowPlayingCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.nowPlayingMaxPage = response.totalPages
            
            for item in response.results {
              self.nowPlayingCollectionVC.addItem(
                self.convertMovieListItem(item)
              )
            }
          }
        }
      }
    } else if identifier == "Latest" {
      if latestCurrentPage < latestMaxPage {
        latestCurrentPage += 1
        
        discoverMovieFetcher?.fetchLatest(page: latestCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.latestMaxPage = response.totalPages
            
            for item in response.results {
              self.latestCollectionVC.addItem(
                self.convertMovieListItem(item)
              )
            }
          }
        }
      }
    } else if identifier == "Upcoming" {
      if upcomingCurrentPage < upcomingMaxPage {
        upcomingCurrentPage += 1
        
        discoverMovieFetcher?.fetchUpcoming(page: upcomingCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.upcomingMaxPage = response.totalPages
            
            for item in response.results {
              self.upcomingCollectionVC.addItem(
                self.convertMovieListItem(item)
              )
            }
          }
        }
      }
    } else if identifier == "Popular" {
      if popularCurrentPage < popularMaxPage {
        popularCurrentPage += 1
        
        discoverMovieFetcher?.fetchPopular(page: popularCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.popularMaxPage = response.totalPages
            
            for item in response.results {
              self.popularCollectionVC.addItem(
                self.convertMovieListItem(item)
              )
            }
          }
        }
      }
    } else if identifier == "TopRated" {
      if topRatedCurrentPage < topRatedMaxPage {
        topRatedCurrentPage += 1
        
        discoverMovieFetcher?.fetchTopRated(page: topRatedCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.topRatedMaxPage = response.totalPages
            
            for item in response.results {
              self.topRatedCollectionVC.addItem(
                self.convertMovieListItem(item)
              )
            }
          }
        }
      }
    }
  }
  
  func itemSelected(_ id: Int, identifier: String) {
    selectedId = id
    performSegue(withIdentifier: "ToMovieDetails", sender: self)
  }
  
  private func convertMovieListItem(_ item: MovieListItem) -> CustomCollectionViewController.ListItem {
    return CustomCollectionViewController.ListItem(id: item.id,
                                                   title: item.title,
                                                   subtitle: item.release_year,
                                                   badge: (item.rating > 0.0 ? String(item.rating) : ""),
                                                   badgeColor: MovieListItem.getBadgeColor(for: item.rating),
                                                   imageURL: item.backdrop_url)
  }
}
