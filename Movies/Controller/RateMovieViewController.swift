//
//  RateMovieViewController.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit
import Cosmos

protocol RateMovieDelegate: AnyObject {
  func onConfirmMovieRating(rating: Int)
  func onDeleteMovieRating()
}

class RateMovieViewController: UIViewController {
  
  // IBOutlets
  @IBOutlet weak var movieTitleLabel: UILabel!
  @IBOutlet weak var cosmosView: CosmosView!
  @IBOutlet weak var deleteButtonHeight: NSLayoutConstraint!
  
  // IBActions
  
  @IBAction func onOK(_ sender: Any) {
    if let rating = rating {
      delegate?.onConfirmMovieRating(rating: rating)
    }
    
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onDelete(_ sender: Any) {
    delegate?.onDeleteMovieRating()
    
    dismiss(animated: true, completion: nil)
  }
  
  // MARK: - Properties
  
  weak var delegate: RateMovieDelegate?
  var movieTitle: String?
  var rating: Int?
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    movieTitleLabel.text = movieTitle
    cosmosView.rating = Double(rating ?? 0)
    
    if rating == nil {
      self.deleteButtonHeight.priority = UILayoutPriority.required
    } else {
      self.deleteButtonHeight.priority = UILayoutPriority.init(1)
    }
    view.layoutIfNeeded()
    
    // Called when user finishes changing the rating by lifting the finger from the view.
    cosmosView.didFinishTouchingCosmos = { [weak self] rating in
      guard let self = self else { return }
      
      self.rating = Int(rating)
      self.deleteButtonHeight.priority = UILayoutPriority.init(1)
      self.view.layoutIfNeeded()
    }
  }
}
