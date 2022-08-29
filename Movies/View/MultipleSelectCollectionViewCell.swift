//
//  MultipleSelectCollectionViewCell.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

class MultipleSelectCollectionViewCell: UICollectionViewCell {
  // IBOutlets
  @IBOutlet weak var labelBackgroundView: UIView!
  @IBOutlet weak var labelView: UILabel!
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    labelBackgroundView?.layer.cornerRadius = 6.0
    labelBackgroundView?.clipsToBounds = true;
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()

    contentView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
     contentView.leftAnchor.constraint(equalTo: leftAnchor),
     contentView.rightAnchor.constraint(equalTo: rightAnchor),
     contentView.topAnchor.constraint(equalTo: topAnchor),
     contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }
}
