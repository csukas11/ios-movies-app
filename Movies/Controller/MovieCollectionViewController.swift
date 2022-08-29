//
//  MovieCollectionViewController.swift
//  Movies
//
//  ViewController responsible for managing the movies collection view.
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit
import Kingfisher

protocol MovieCollectionDelegate {
  func loadNextPage()
}

class CustomCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  // Delegate to notify our data source about the need of loading the next page
  private var delegate: MovieCollectionDelegate?
  
  // Array to store displayed movies
  private var _data: [MovieListItem] = [MovieListItem]()
  // Number of movies in the collection view
  var itemCount: Int { get { _data.count } }
  
  
  
  // Set the network provider
  func setDelegate(_ delegate: MovieCollectionDelegate) {
    self.delegate = delegate
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set delegates
    collectionView.dataSource = self
    collectionView.delegate = self
  }
  
  // MARK: - Collection View Data manipulation
  
  // Add a single item to the colleciton view
  func addItem(_ item: MovieListItem) {
    collectionView.performBatchUpdates({
      let indexPath = IndexPath(row: self._data.count, section: 0)
      self._data.append(item)
      collectionView.insertItems(at: [indexPath])
    }, completion: nil)
  }
  
  // Add an array of items to the collection view
  func addItems(_ items: [MovieListItem]) {
    for movie in items {
      addItem(movie)
    }
  }
  
  // Remove all items from the collection view
  func clearItems() {
    _data = []
    collectionView.reloadData()
  }

  // MARK: - UICollectionViewDataSource
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return _data.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Load next page if the last item is displayed
    if indexPath.row != 0 && indexPath.row == (self.itemCount - 1) {
      delegate?.loadNextPage()
    }
    
    // prepare cell for display
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
    
    let movie = _data[indexPath.row]
    
    if let posterImage = cell.posterImageView {
      if movie.poster_url != "" {
        if let url = URL(string: movie.poster_url) {
          let processor = DownsamplingImageProcessor(size: posterImage.frame.size)
          posterImage.kf.indicatorType = .activity
          posterImage.kf.setImage(
              with: url,
              options: [
                  .processor(processor),
                  .scaleFactor(UIScreen.main.scale),
                  .transition(.fade(1)),
                  .cacheOriginalImage
          ])
        }
      }
    }
    
    if !movie.title.isEmpty {
      cell.titleLabel?.text = movie.title
    } else {
      cell.titleLabel?.text = ""
    }
    
    cell.ratingLabel?.text = movie.release_year
    
    if movie.rating != 0.0 {
      cell.ratingLabel?.text = String(movie.rating)
      switch movie.rating {
      case 0.1..<5.0:
        cell.ratingLabelBackground?.backgroundColor = UIColor(displayP3Red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
      case 5.0..<8.0:
        cell.ratingLabelBackground?.backgroundColor = UIColor(displayP3Red: 0.80, green: 0.56, blue: 0.0, alpha: 1.0)
      case 8.0..<10.1:
        cell.ratingLabelBackground?.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.75, blue: 0.13, alpha: 1.0)
      default:
        cell.ratingLabelBackground?.backgroundColor = UIColor.gray
      }
      cell.ratingLabelBackground?.isHidden = false
    } else {
      cell.ratingLabel?.text = ""
      cell.ratingLabelBackground?.isHidden = true
    }
    
    return cell
  }

  // MARK: - UICollectionViewDelegate
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    // TODO: - Open detailed screen
    // Temporary solution to open in browser
//    let movie = _data[indexPath.row]
//    guard let url = URL(string: "https://www.themoviedb.org/movie/\(movie.id)") else { return }
//    UIApplication.shared.open(url)
  }
  
}

// MARK: - Format number space between thousands
//extension Formatter {
//  static let withSeparator: NumberFormatter = {
//    let formatter = NumberFormatter()
//    formatter.groupingSeparator = " "
//    formatter.numberStyle = .decimal
//    return formatter
//  }()
//}
//extension Numeric {
//  var formattedWithSeparator: String {
//    return Formatter.withSeparator.string(for: self) ?? ""
//  }
//}
