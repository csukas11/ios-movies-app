//
//  CustomCollectionViewController.swift
//  SnapSoft-Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit
import Kingfisher

protocol CustomCollectionDelegate: AnyObject {
  func loadNextPage(identifier: String)
  func itemSelected(_ id: Int, identifier: String)
}

extension CustomCollectionViewController {
  struct ListItem {
    var id: Int = 0
    var title: String = ""
    var subtitle: String = ""
    var badge: String = ""
    var badgeColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    var imageURL: String = ""
  }

}

class CustomCollectionViewController: UIViewController  {
  
  // Margins for the Collection View
  var marginTopBottom: CGFloat = 20
  var marginLeftRight: CGFloat = 20
  var marginBetweenItems: CGFloat = 20
  
  ///------------------------------------------------------------------
  
  // IBOutlets
  @IBOutlet weak var collectionView: UICollectionView!
  
  // MARK: - Properties
  
  // Size of the cells
  var spacing: CGFloat {
    get {
      if direction == .vertical {
        return marginBetweenItems
      } else {
        return marginBetweenItems * 0.5
      }
    }
  }
  var cellWidth: Double { 0.0  }
  var cellHeight: Double { 0.0 }
  
  // Delegate to notify our data source about the need of loading the next page
  private var identifier = ""
  private weak var delegate: CustomCollectionDelegate?
  
  // Direction
  private var direction: UICollectionView.ScrollDirection = .vertical
  var scrollDirection: UICollectionView.ScrollDirection {
    get { direction }
    set {
      direction = newValue
      if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
        layout.scrollDirection = direction
      }
    }
  }
  
  // Image content mode
  var imageContentMode = UIImageView.ContentMode.scaleAspectFill
  
  // Default image
  var defaultImage = UIImage(named: "NoBackdrop") ?? UIImage()
  // Default image content mode
  var defaultImageContentMode = UIImageView.ContentMode.scaleAspectFill
  
  // Refresh Control
  weak var refreshControl: UIRefreshControl?
  
  // Array to store displayed items
  private var _data: [ListItem] = [ListItem]()
  // Number of items in the collection view
  var itemCount: Int { _data.count }
  
  // MARK: - Funcitons
  
  // Set the delegate
  func setDelegate(_ delegate: CustomCollectionDelegate, identifier: String = "") {
    self.identifier = identifier
    self.delegate = delegate
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    collectionView.register(CustomCollectionViewCell.nib(), forCellWithReuseIdentifier: CustomCollectionViewCell.identifier)
    
    // set direction
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        layout.scrollDirection = direction
    }
    
    // set delegates
    collectionView.dataSource = self
    collectionView.delegate = self
    
    // Init margins depending on the display's type
    if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//      if UIDevice.current.hasNotch {
          layout.sectionInset = UIEdgeInsets(
            top: marginTopBottom,
            left: marginLeftRight,
            bottom: marginTopBottom,
            right: marginLeftRight
          )
//      }
      
      layout.minimumInteritemSpacing = self.spacing
      layout.minimumLineSpacing = self.spacing
      
      layout.invalidateLayout()
      
      // Set refresh control
      if let refreshControl = refreshControl {
        collectionView.refreshControl = refreshControl
      }
    }
  }
  
  // MARK: - Collection View Data manipulation
  
  // Add a single item to the colleciton view
  func addItem(_ item: ListItem) {
    collectionView.performBatchUpdates({
      let indexPath = IndexPath(row: self._data.count, section: 0)
      self._data.append(item)
      collectionView.insertItems(at: [indexPath])
    }, completion: nil)
  }
  
  // Add an array of items to the collection view
  func addItems(_ items: [ListItem]) {
    for item in items {
      addItem(item)
    }
  }
  
  // Remove all items from the collection view
  func clearItems() {
    _data = []
    collectionView.reloadData()
  }
  
}

// MARK: - UICollectionViewDataSource
  
extension CustomCollectionViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return _data.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // Load next page if the last item is displayed
    if indexPath.row != 0 && indexPath.row == (self.itemCount - 1) {
      delegate?.loadNextPage(identifier: identifier)
    }
    
    // prepare cell for display
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.identifier, for: indexPath) as! CustomCollectionViewCell
    
    let item = _data[indexPath.row]
    
    cell.imageView.image = defaultImage
    cell.imageView.contentMode = defaultImageContentMode
    if !item.imageURL.isEmpty {
      if let url = URL(string: item.imageURL) {
        cell.imageView.contentMode = imageContentMode
        let processor = DownsamplingImageProcessor(size: cell.imageView.frame.size)
        cell.imageView.kf.indicatorType = .activity
        cell.imageView.kf.setImage(
            with: url,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
        ])
      }
    }
    
    cell.titleLabel?.text = item.title
    cell.subtitleLabel?.text = item.subtitle
    
    cell.badgeLabel?.text = item.badge
    cell.badgeLabelBackground?.backgroundColor = item.badgeColor
    if item.badge.isEmpty {
      cell.badgeLabelBackground?.isHidden = true
    } else {
      cell.badgeLabelBackground?.isHidden = false
    }
    
    return cell
  }
}

// MARK: - UICollectionViewDelegate

extension CustomCollectionViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    
    delegate?.itemSelected(_data[indexPath.row].id, identifier: self.identifier)
  }
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    if direction == .horizontal {
      if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
        let cellWidthIncludeSpacing = CGFloat(self.cellWidth) + layout.minimumLineSpacing
        
        let index = round((targetContentOffset.pointee.x + scrollView.contentInset.left) / cellWidthIncludeSpacing)
        
        targetContentOffset.pointee = CGPoint(x: index * cellWidthIncludeSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
      }
    }
  }
}
  
// MARK: - UICollectionViewDelegateFlowLayout
  
extension CustomCollectionViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    return CGSize(width: cellWidth, height: cellHeight)
  }
  
}

// MARK: - UIDevice.hasNotch
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
