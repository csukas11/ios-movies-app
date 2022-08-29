//
//  CustomCollectionViewCell.swift
//  SnapSoft-Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import Foundation
import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
  // IBOutlets
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  @IBOutlet weak var badgeLabelBackground: UIView!
  @IBOutlet weak var badgeLabel: UILabel!
  
  static let identifier = "CustomCollectionViewCell"
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    badgeLabelBackground?.layer.cornerRadius = 6.0
    badgeLabelBackground?.clipsToBounds = true;
    
    imageView?.layer.cornerRadius = 6.0
    imageView?.clipsToBounds = true;
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  static func nib() -> UINib {
    return UINib(nibName: "CustomCollectionViewCell", bundle: nil)
  }

}
