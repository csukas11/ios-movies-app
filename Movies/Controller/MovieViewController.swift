//
//  MovieViewController.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftPhotoGallery

extension MovieViewController {
  enum State {
    case loading
    case ready
    case error(String)
  }
}

class MovieViewController: UIViewController {
  
  // IBOutlets
  @IBOutlet weak var scrollView: UIScrollView!
    
  @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
  
  @IBOutlet weak var backdropImage: UIImageView!
  @IBOutlet weak var backdropImageHeight: NSLayoutConstraint!
  @IBOutlet weak var backdropImageBottom: NSLayoutConstraint!

  @IBOutlet weak var originalTitleLabel: UILabel!
  @IBOutlet weak var metaLineLabel: UILabel!
  
  @IBOutlet weak var ratingScoreLabel: UILabel!
  @IBOutlet weak var ratingCountLabel: UILabel!
  
  @IBOutlet weak var userNotRatedHeight: NSLayoutConstraint!
  @IBOutlet weak var userRatedHeight: NSLayoutConstraint!
  @IBOutlet weak var userRatingScoreLabel: UILabel!
  
  @IBOutlet weak var watchlistImage: UIImageView!
  
  @IBOutlet weak var trailersViewHeight: NSLayoutConstraint!
  @IBOutlet weak var trailersContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var galleryViewHeight: NSLayoutConstraint!
  @IBOutlet weak var galleryButtonBg: UIView!
  
  @IBOutlet weak var overviewContainerHeight: NSLayoutConstraint!
  @IBOutlet weak var overviewBottom: NSLayoutConstraint!
  @IBOutlet weak var overviewText: UILabel!
  
  @IBOutlet weak var creditViewHeight: NSLayoutConstraint!
  @IBOutlet weak var creditContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var recommendedViewHeight: NSLayoutConstraint!
  @IBOutlet weak var recommendedContainerHeight: NSLayoutConstraint!
  
  @IBOutlet weak var similarViewHeight: NSLayoutConstraint!
  @IBOutlet weak var similarContainerHeight: NSLayoutConstraint!
  
  // Handle UI actions
  
  @objc private func openTMDbPage() {
    guard let urlObj = URL(string: "https://www.themoviedb.org/movie/\(movieID)") else { return }
    UIApplication.shared.open(urlObj)
  }

  @IBAction func onRatingTap(_ sender: Any) {
    if let isLoggedIn = authenticationFetcher?.isUserAuthenticated(),
       isLoggedIn {
      
      performSegue(withIdentifier: "RateMovieSegue", sender: self)
    } else {
      authenticationFetcher?.authenticate() { url, error in
        guard let authUrl = url,
              let urlObj = URL(string: authUrl) else { return }
        
        UIApplication.shared.open(urlObj)
      }
    }
  }
  
  @IBAction func onWatchlistTap(_ sender: Any) {
    if let isLoggedIn = authenticationFetcher?.isUserAuthenticated(),
       isLoggedIn {
      
      if isOnWatchlist {
        movieFetcher?.removeFromWatchlist(id: movieID) { error in }
        isOnWatchlist = false
      } else {
        movieFetcher?.addToWatchlist(id: movieID) { error in }
        isOnWatchlist = true
      }
      updateAccountStateView()
    } else {
      authenticationFetcher?.authenticate() { url, error in
        guard let authUrl = url,
              let urlObj = URL(string: authUrl) else { return }
        
        UIApplication.shared.open(urlObj)
      }
    }
  }
  
  @IBAction func onGallery(_ sender: Any) {
    if let gallery = gallery {
      present(gallery, animated: true, completion: nil)
    }
  }
  
  // MARK: - Properties
  
  // View State
  private var state: State = .ready {
    didSet {
      switch state {
      case .ready:
        loadingSpinner?.hideSpinner()
        contentViewHeight.priority = UILayoutPriority.init(1)
        view.layoutIfNeeded()
      case .loading:
        contentViewHeight.priority = UILayoutPriority.required
        view.layoutIfNeeded()
        loadingSpinner?.showSpinner()
      case .error(let msg):
        loadingSpinner?.hideSpinner()
        print(msg)
      }
    }
  }
  
  // Fetchers
  var authenticationFetcher: AuthenticationFetcher? = TMDbAuthenticationFetcher()
  var movieFetcher: MovieFetcher? = TMDbMovieFetcher()
  var recommendFetcher: RecommendMovieFetcher? = TMDbRecommendMovieFetcher()
  var similarFetcher: SimilarMovieFetcher? = TMDbSimilarMovieFetcher()
  
  // Movie
  var movieID = 0
  private var movie: Movie?
  // Account
  private var isFavorite = false
  private var isOnWatchlist = false
  private var movieRating: Int?
  // Gallery
  private var gallery: SwiftPhotoGallery?
  private var images = [UIImage]()
  // Trailers
  private var trailersCollectionVC: CustomCollectionViewController!
  private var trailerURLs = [String]()
  // Credits
  private var creditsCollectionVC: CustomCollectionViewController!
  // Recommended movies
  private var recommendCurrentPage = 0
  private var recommendMaxPage = 1
  private var recommendCollectionVC: CustomCollectionViewController!
  // Similar movies
  private var similarCurrentPage = 0
  private var similarMaxPage = 1
  private var similarCollectionVC: CustomCollectionViewController!
  
  // Loading spinner
  private var loadingSpinner: LoadingSpinner? = nil
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // check ongoing login
    NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    
    // nav title
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .automatic
    navigationItem.title = ""
    
    // add right navigation bar button
    if #available(iOS 13.0, *) {
      navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "network"), style: .plain, target: self, action: #selector(self.openTMDbPage))
    } else {
      navigationItem.rightBarButtonItem = UIBarButtonItem(title: "TMDb Adatlap", style: .plain, target: self, action: #selector(self.openTMDbPage))
    }
    
    loadingSpinner = LoadingSpinner(on: view)
    state = .loading
    
    // Gallery
    gallery = SwiftPhotoGallery(delegate: self, dataSource: self)
    gallery?.backgroundColor = UIColor.black
    gallery?.pageIndicatorTintColor = UIColor.gray.withAlphaComponent(0.5)
    gallery?.currentPageIndicatorTintColor = UIColor.white
    gallery?.hidePageControl = false
    
    // UI resizing
    // Gallery button
    galleryButtonBg.layer.cornerRadius = 6.0
    galleryButtonBg.clipsToBounds = true
    // CollectionView heights
    trailersContainerHeight.constant = CGFloat(trailersCollectionVC.cellHeight)
    creditContainerHeight.constant = CGFloat(creditsCollectionVC.cellHeight)
    recommendedContainerHeight.constant = CGFloat(recommendCollectionVC.cellHeight)
    similarContainerHeight.constant = CGFloat(similarCollectionVC.cellHeight)
    // Hide till loaded
    creditViewHeight.priority = UILayoutPriority.required
    recommendedViewHeight.priority = UILayoutPriority.required
    similarViewHeight.priority = UILayoutPriority.required
    view.layoutIfNeeded()
    
    loadContent()
  }
  
  @objc func applicationDidBecomeActive(notification: NSNotification) {
    // Check ongoing auth
    authenticationFetcher?.updateAuthenticationState() { [weak self] error in
      if error == nil {
        self?.loadAccountState()
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.loadAccountState()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "ToTrailerCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "Trailer")
        viewController.defaultImage = UIImage(named: "NoTrailer") ?? UIImage()
        setCollectionViewController(viewController)
        trailersCollectionVC = viewController
      }
    } else if segue.identifier == "ToCreditsCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "Credits")
        viewController.defaultImage = UIImage(named: "NoProfile") ?? UIImage()
        setCollectionViewController(viewController)
        creditsCollectionVC = viewController
      }
    } else if segue.identifier == "ToRecommendedCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "Recommended")
        viewController.defaultImage = UIImage(named: "NoPoster") ?? UIImage()
        setCollectionViewController(viewController)
        recommendCollectionVC = viewController
      }
    } else if segue.identifier == "ToSimilarCollection" {
      if let viewController = segue.destination as? CustomCollectionViewController {
        viewController.setDelegate(self, identifier: "Similar")
        viewController.defaultImage = UIImage(named: "NoPoster") ?? UIImage()
        setCollectionViewController(viewController)
        similarCollectionVC = viewController
      }
    } else if segue.identifier == "RateMovieSegue" {
      if let viewController = segue.destination as? RateMovieViewController {
        viewController.delegate = self
        viewController.movieTitle = movie?.title ?? ""
        viewController.rating = movieRating
      }
    }
  }
  
  private func setCollectionViewController(_ cv: CustomCollectionViewController) {
    cv.scrollDirection = .horizontal
    cv.defaultImageContentMode = .center
  }
  
  override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
    if identifier == "RateMovieSegue" {
      if let loggedIn = authenticationFetcher?.isUserAuthenticated(),
         loggedIn {
        return true
      } else {
        return false
      }
    }
    
    return true
  }
  
  func loadContent() {
    state = .loading
    
    scrollView.setContentOffset(.zero, animated: false)
    
    trailersCollectionVC.clearItems()
    creditsCollectionVC.clearItems()
    similarCollectionVC.clearItems()
    similarCurrentPage = 0
    recommendCollectionVC.clearItems()
    recommendCurrentPage = 0
    
    // Load the movie details
    loadMovieDetails()
    loadAccountState()
    loadCredits()
    loadNextPage(identifier: "Similar")
    loadNextPage(identifier: "Recommended")
  }
  
  // MARK: - Load data with fetchers
  
  func loadMovieDetails() {
    movieFetcher?.fetch(for: movieID) { [weak self] response, error in
      guard let self = self else { return }
      
      if let response = response {
        self.movie = response
        self.updateMovieView()
        
        for item in response.images {
          DispatchQueue.global().async { [weak self, item] in
            guard let self = self else { return }
            
            if let url = URL(string: item.url),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
              
              DispatchQueue.main.async {
                self.images.append(image)
                self.gallery?.reloadInputViews()
              }
            }
          }
        }
        self.updateGalleryView()
        
        for item in response.videos {
          self.trailerURLs.append(item.url)
          self.trailersCollectionVC.addItem(
            CustomCollectionViewController.ListItem(id: self.trailerURLs.count-1,
                                     title: item.name,
                                     subtitle: item.site,
                                     imageURL: "https://i3.ytimg.com/vi/\(item.key)/maxresdefault.jpg")
          )
        }
        self.updateTrailerView()
        
        self.state = .ready
      }
    }
  }
  
  func loadAccountState() {
    let isLoggedIn = authenticationFetcher?.isUserAuthenticated() ?? false
    if isLoggedIn {
      movieFetcher?.fetchAccountState(for: movieID) { [weak self] response, error in
        guard let self = self else { return }
        
        if let response = response {
          self.isFavorite = response.isFavorite
          self.isOnWatchlist = response.isOnWatchlist
          self.movieRating = response.rating
          
          self.updateAccountStateView()
        }
      }
    }
    
  }
  
  func loadCredits() {
    movieFetcher?.fetchCredits(for: movieID) { [weak self] response, error in
      guard let self = self else { return }
      
      if let response = response {
        self.creditsCollectionVC.clearItems()
        
        for item in response.cast {
          self.creditsCollectionVC.addItem(
            CustomCollectionViewController.ListItem(id: item.id,
                                     title: item.name,
                                     subtitle: item.character,
                                     imageURL: item.profile_url ?? "")
          )
        }
        for item in response.crew {
          self.creditsCollectionVC.addItem(
            CustomCollectionViewController.ListItem(id: item.id,
                                     title: item.name,
                                     subtitle: item.job,
                                     imageURL: item.profile_url ?? "")
          )
        }
        
        self.updateCreditView()
      }
    }
  }
  
  // MARK: - Update view states
  
  func updateGalleryView() {
    if let movie = movie {
      if movie.images.count > 0, galleryViewHeight.priority == UILayoutPriority.required {
        galleryViewHeight.priority = UILayoutPriority.init(1)
        view.layoutIfNeeded()
      } else if movie.images.count == 0, galleryViewHeight.priority != UILayoutPriority.required {
        galleryViewHeight.priority = UILayoutPriority.required
        view.layoutIfNeeded()
      }
    }
  }
  
  func updateMovieView() {
    if let movie = movie {
      navigationItem.title = movie.title
      
      if let backdrop = movie.backdrop_url,
         !backdrop.isEmpty {
        if let url = URL(string: backdrop) {
          let width = backdropImage.frame.size.width
          let height = width * (9/16)
          
          let processor = DownsamplingImageProcessor(size: CGSize(width: width, height: height))
          backdropImage.kf.indicatorType = .activity
          backdropImage.kf.setImage(
              with: url,
              options: [
                  .processor(processor),
                  .scaleFactor(UIScreen.main.scale),
                  .transition(.fade(1)),
                  .cacheOriginalImage
          ])
          
          backdropImageHeight.constant = height
          backdropImageBottom.priority = UILayoutPriority.init(1)
        }
      } else {
        backdropImageHeight.constant = 0
        backdropImageBottom.priority = UILayoutPriority.required
      }
      
      originalTitleLabel.text = movie.original_title
      
      var metaLine = [String]()
      metaLine.append(movie.release_year)
      if movie.genres.count > 0 {
        metaLine.append(movie.genres[0].name)
      }
      if let runtime = movie.runtime,
      runtime > 0 {
        metaLine.append("\(runtime) minutes")
      }
      metaLineLabel.text = metaLine.joined(separator: " • ")
      
      ratingScoreLabel.text = String(Int(movie.vote_average)) + "/10"
      ratingCountLabel.text = String(movie.vote_count)
      
      if let overview = movie.overview,
         !overview.isEmpty {
        overviewText.text = overview
        overviewContainerHeight.priority = UILayoutPriority.init(1)
        overviewBottom.priority = UILayoutPriority.init(1)
      } else {
        overviewText.text = ""
        overviewContainerHeight.priority = UILayoutPriority.required
        overviewBottom.priority = UILayoutPriority.required
      }
    }
    
    view.layoutIfNeeded()
  }
  
  func updateAccountStateView() {
    // Rating
    if let rating = movieRating {
      userRatingScoreLabel.text = String(rating) + "/10"
      
      if userRatedHeight.priority == UILayoutPriority.required {
        userRatedHeight.priority = UILayoutPriority.init(1)
      }
      if userNotRatedHeight.priority != UILayoutPriority.required {
        userNotRatedHeight.priority = UILayoutPriority.required
      }
    } else {
      if userNotRatedHeight.priority == UILayoutPriority.required {
        userNotRatedHeight.priority = UILayoutPriority.init(1)
      }
      if userRatedHeight.priority != UILayoutPriority.required {
        userRatedHeight.priority = UILayoutPriority.required
      }
    }
    
    // Watchlist
    if isOnWatchlist {
      watchlistImage.image = UIImage(systemName: "bookmark.fill")
    } else {
      watchlistImage.image = UIImage(systemName: "bookmark")
    }
    
    view.layoutIfNeeded()
  }
  
  func updateTrailerView() {
    if trailersCollectionVC.itemCount > 0, trailersViewHeight.priority == UILayoutPriority.required {
      trailersViewHeight.priority = UILayoutPriority.init(1)
    } else if trailersCollectionVC.itemCount == 0, trailersViewHeight.priority != UILayoutPriority.required {
      trailersViewHeight.priority = UILayoutPriority.required
    }
    view.layoutIfNeeded()
  }
  
  func updateCreditView() {
    if creditsCollectionVC.itemCount > 0, creditViewHeight.priority == UILayoutPriority.required {
      creditViewHeight.priority = UILayoutPriority.init(1)
    } else if creditsCollectionVC.itemCount == 0, creditViewHeight.priority != UILayoutPriority.required {
      creditViewHeight.priority = UILayoutPriority.required
    }
    view.layoutIfNeeded()
  }
  
  func updateRecommendedView() {
    if recommendCollectionVC.itemCount > 0, recommendedViewHeight.priority == UILayoutPriority.required {
      recommendedViewHeight.priority = UILayoutPriority.init(1)
    } else if recommendCollectionVC.itemCount == 0, recommendedViewHeight.priority != UILayoutPriority.required {
      recommendedViewHeight.priority = UILayoutPriority.required
    }
    view.layoutIfNeeded()
  }
  
  func updateSimilarView() {
    if similarCollectionVC.itemCount > 0, similarViewHeight.priority == UILayoutPriority.required {
      similarViewHeight.priority = UILayoutPriority.init(1)
    } else if similarCollectionVC.itemCount == 0, similarViewHeight.priority != UILayoutPriority.required {
      similarViewHeight.priority = UILayoutPriority.required
    }
    view.layoutIfNeeded()
  }
  
}
  
// MARK: - CustomCollectionDelegate

extension MovieViewController: CustomCollectionDelegate {
  func loadNextPage(identifier: String) {
    if identifier == "Recommended" {
      if recommendCurrentPage < recommendMaxPage {
        recommendCurrentPage += 1
        
        recommendFetcher?.fetch(for: movieID, page: recommendCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.recommendMaxPage = response.totalPages
            
            for item in response.results {
              self.recommendCollectionVC.addItem(
                CustomCollectionViewController.ListItem(id: item.id,
                                         title: item.title,
                                         subtitle: item.release_year,
                                         badge: (item.rating > 0.0 ? String(item.rating) : ""),
                                         badgeColor: MovieListItem.getBadgeColor(for: item.rating),
                                         imageURL: item.backdrop_url)
              )
            }
            
            if response.page == 1 {
              self.updateRecommendedView()
            }
          }
        }
      }
    } else if identifier == "Similar" {
      if similarCurrentPage < similarMaxPage {
        similarCurrentPage += 1
        
        similarFetcher?.fetch(for: movieID, page: similarCurrentPage) { [weak self] response, error in
          guard let self = self else { return }
          
          if let response = response {
            self.similarMaxPage = response.totalPages
            
            for item in response.results {
              self.similarCollectionVC.addItem(
                CustomCollectionViewController.ListItem(id: item.id,
                                         title: item.title,
                                         subtitle: item.release_year,
                                         badge: (item.rating > 0.0 ? String(item.rating) : ""),
                                         badgeColor: MovieListItem.getBadgeColor(for: item.rating),
                                         imageURL: item.backdrop_url)
              )
            }
            
            if response.page == 1 {
              self.updateSimilarView()
            }
          }
        }
      }
    }
  }
  
  func itemSelected(_ id: Int, identifier: String) {
    if identifier == "Trailer" {
      if let url = URL(string: trailerURLs[id]) {
        UIApplication.shared.open(url)
      }
    } else if identifier == "Credits" {
        guard let urlObj = URL(string: "https://www.themoviedb.org/person/\(id)") else { return }
        UIApplication.shared.open(urlObj)
    } else if identifier == "Recommended" || identifier == "Similar" {
      movieID = id
      loadContent()
    }
  }
}
  
// MARK: - SwiftPhotoGalleryDataSource
 
extension MovieViewController: SwiftPhotoGalleryDataSource {
  func numberOfImagesInGallery(gallery: SwiftPhotoGallery) -> Int {
    return images.count
  }

  func imageInGallery(gallery: SwiftPhotoGallery, forIndex: Int) -> UIImage? {
    return images[forIndex]
  }
}
  
// MARK: - SwiftPhotoGalleryDelegate
  
extension MovieViewController: SwiftPhotoGalleryDelegate {
  func galleryDidTapToClose(gallery: SwiftPhotoGallery) {
    dismiss(animated: true, completion: nil)
  }
 }
  
// MARK: - RateMovieDelegate
   
extension MovieViewController: RateMovieDelegate {
  func onConfirmMovieRating(rating: Int) {
    movieFetcher?.rateMovie(id: movieID, rating: rating) { _ in }
    movieRating = rating
    isOnWatchlist = false
    updateAccountStateView()
  }
  
  func onDeleteMovieRating() {
    movieFetcher?.removeMovieRating(id: movieID) { _ in }
    movieRating = nil
    updateAccountStateView()
  }
}
