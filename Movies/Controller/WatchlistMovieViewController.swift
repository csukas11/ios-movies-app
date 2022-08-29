//
//  WatchlistMovieViewController.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Foundation
import UIKit

extension WatchlistMovieViewController {
  enum State {
    case loading
    case ready
    case error(String)
  }
  
  enum UserState {
    case loggedIn
    case loggedOut
  }
}

class WatchlistMovieViewController: UIViewController {
  
  // The navigatin bar title
  private static let WINDOW_TITLE = "Watchlist"
  // Back button title
  private static let BACK_BUTTON_TITLE = "Watchlist"
  
  ///------------------------------------------------------------------
  
  // IBOutlets
  @IBOutlet weak var userNotLoggedInHeight: NSLayoutConstraint!
  @IBOutlet weak var userLoggedInHeight: NSLayoutConstraint!
  @IBOutlet weak var logInButtonBg: UIView!
  
  // MARK: - Onclick listeners
  
  @IBAction func onLogIn(_ sender: Any) {
    if let loggedIn = authenticationFetcher?.isUserAuthenticated(),
       loggedIn {
      
      loadWatchlistData()
    } else {
      authenticationFetcher?.authenticate() { url, error in
        guard let authUrl = url,
              let urlObj = URL(string: authUrl) else { return }
        
        UIApplication.shared.open(urlObj)
      }
    }
  }
  
  @objc private func onLogOut() {
    userState = .loggedOut
    authenticationFetcher?.terminateSession(completion: nil)
    self.userLoggedInHeight.priority = UILayoutPriority.required
    self.userNotLoggedInHeight.priority = UILayoutPriority.init(1)
  }
  
  @objc private func refreshData(_ sender: Any) {
    refreshControl.endRefreshing()
    loadWatchlistData()
  }
  
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
  
  // User State
  private var userState: UserState = .loggedOut {
    didSet {
      switch userState {
      case .loggedIn:
        // add right navigation bar button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(self.onLogOut))
      case .loggedOut:
        navigationItem.setRightBarButton(nil, animated: false)
      }
    }
  }
  
  // Fetchers
  var watchlistMovieFetcher: WatchlistMovieFetcher? = TMDbWatchlistMovieFetcher()
  var authenticationFetcher: AuthenticationFetcher? = TMDbAuthenticationFetcher()
  
  // Selected movie id
  private var selectedId = 0
  
  // Page params
  private var currentPage = 0
  private var maxPage = 1
  
  private var loadingSpinner: LoadingSpinner? = nil
  private var collectionVC: CustomCollectionViewController!
  private var refreshControl = UIRefreshControl()
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadingSpinner = LoadingSpinner(on: view)
    state = .loading
    
    // check ongoing login
    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    
    // Nav title
    navigationItem.title = WatchlistMovieViewController.WINDOW_TITLE
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .automatic
    
    // Back button
    let backItem = UIBarButtonItem()
    backItem.title = WatchlistMovieViewController.BACK_BUTTON_TITLE
    navigationItem.backBarButtonItem = backItem
    
    // UI resizing
    // Log In button
    logInButtonBg.layer.cornerRadius = 6.0
    logInButtonBg.clipsToBounds = true
    // Hide everything
    userLoggedInHeight.priority = UILayoutPriority.required
    userNotLoggedInHeight.priority = UILayoutPriority.required
    view.layoutIfNeeded()
    
    // Configure Refresh Control
    refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    
    loadWatchlistData()
  }
  
  @objc func applicationDidBecomeActive(notification: NSNotification) {
    // Check ongoing auth
    authenticationFetcher?.updateAuthenticationState() { [weak self] error in
      guard let self = self else { return }
      
      if error == nil {
        self.loadWatchlistData()
      }
    }
  }
  
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToWatchlistCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self)
        viewController.defaultImage = UIImage(named: "NoPoster") ?? UIImage()
        viewController.defaultImageContentMode = .center
        viewController.refreshControl = refreshControl
        collectionVC = viewController
      }
    } else if segue.identifier == "ToMovieDetails" {
      if let viewController = segue.destination as? MovieViewController {
        viewController.movieID = selectedId
      }
    }
  }
  
  func loadWatchlistData() {
    self.state = .loading
    
    if let isLoggedIn = authenticationFetcher?.isUserAuthenticated(),
       isLoggedIn {
      
      authenticationFetcher?.getUserAccountDetails() { [weak self] result, error in
        guard let self = self else { return }
        
        if let account = result {
          // self.userNameLabel.text = account.username
          self.userState = .loggedIn
          self.loadNextPage(identifier: "")
          self.userLoggedInHeight.priority = UILayoutPriority.init(1)
          self.userNotLoggedInHeight.priority = UILayoutPriority.required
          self.state = .ready
          self.collectionVC.clearItems()
          self.currentPage = 0
          self.loadNextPage(identifier: "")
        }
      }
    } else {
      self.userState = .loggedOut
      self.userLoggedInHeight.priority = UILayoutPriority.required
      self.userNotLoggedInHeight.priority = UILayoutPriority.init(1)
      self.state = .ready
    }
  }
  
}
  
// MARK: - CustomCollectionDelegate
extension WatchlistMovieViewController: CustomCollectionDelegate {
  func loadNextPage(identifier: String) {
    if currentPage < maxPage {
      currentPage += 1
      
      watchlistMovieFetcher?.fetch(page: currentPage) { [weak self] response, error in
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
