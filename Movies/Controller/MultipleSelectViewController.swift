//
//  MultipleSelectViewController.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit
import AlignedCollectionViewFlowLayout

protocol MultipleSelectDelegate: AnyObject {
  func itemSelected(_ item: MultipleSelectViewController.ListItem, identifier: String)
  func itemDeselected(_ item: MultipleSelectViewController.ListItem, identifier: String)
  func filterItems(_ query: String?, identifier: String)
}

extension MultipleSelectViewController {
  struct ListItem {
    var id: Int
    var name: String
  }
}

class MultipleSelectViewController: UIViewController {
  
  // IBOutlets
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
  
  // IBActions
  @IBAction func onFilter(_ sender: UITextField) {
    if let text = sender.text {
      filterQuery = text
    }
    
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.delayedFilter), object: nil)
    self.perform(#selector(self.delayedFilter), with: nil, afterDelay: 0.75)
  }
  
  // Perform the previously delayed search
  @objc private func delayedFilter() {
    delegate?.filterItems(filterQuery, identifier: identifier)
  }
  
  // MARK: - Properties
  
  // Delegate to notify our data source about changing selected values
  private var identifier = ""
  private weak var delegate: MultipleSelectDelegate?
  
  private var selectedOptions = [ListItem]()
  private var filterQuery: String?
  
  private var options = [ListItem]()
  var optionsCount: Int { options.count }
  
  // MARK: - Funcitons
  
  // Set the network provider
  func setDelegate(_ delegate: MultipleSelectDelegate, identifier: String = "") {
    self.delegate = delegate
    self.identifier = identifier
  }
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set delegates
    collectionView.dataSource = self
    collectionView.delegate = self
    tableView.dataSource = self
    tableView.delegate = self
    
    // set layout for collection view
    // let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left, verticalAlignment: .top)
    // layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    // collectionView.collectionViewLayout = layout
    
    // refresh UI
    collectionViewHeight.constant = min(collectionView.collectionViewLayout.collectionViewContentSize.height, 300)
    self.view.layoutIfNeeded()
  }

  
  // MARK: - Data manipulation
  
  // Add a single item to the selected options list
  func addSelectedOptionItem(_ item: ListItem) {
    let indexPath = IndexPath(row: self.selectedOptions.count, section: 0)
    self.selectedOptions.append(item)
    
    if let collectionView = collectionView {
      collectionView.performBatchUpdates({
        UIView.performWithoutAnimation {
          // collection
          collectionView.insertItems(at: [indexPath])
          
          // refresh UI
          collectionViewHeight.constant = min(collectionView.collectionViewLayout.collectionViewContentSize.height, 300)
          self.view.layoutIfNeeded()
        }
      }, completion: nil)
    }
  }
  
  // Add an array of items to the selected options list
  func addSelectedOptionItems(_ items: [ListItem]) {
    for item in items {
      addSelectedOptionItem(item)
    }
  }
  
  // Remove all items from the selected options list
  func clearSelectedOptionItems() {
    selectedOptions = []
    
    if let collectionView = collectionView {
      collectionView.reloadData()
      
      // refresh UI
      collectionViewHeight.constant = min(collectionView.collectionViewLayout.collectionViewContentSize.height, 300)
      self.view.layoutIfNeeded()
    }
  }
  
  // Add a single item to the options list
  func addOptionItem(_ item: ListItem) {
    let indexPath = IndexPath(row: self.options.count, section: 0)
    self.options.append(item)
    
    if let tableView = tableView {
      tableView.performBatchUpdates({
        tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.none)
      }, completion: nil)
    }
  }
  
  // Add an array of items to the options list
  func addOptionItems(_ items: [ListItem]) {
    for item in items {
      addOptionItem(item)
    }
  }
  
  // Remove all items from the options list
  func clearOptionItems() {
    options = []
    
    if let tableView = tableView {
      tableView.reloadData()
    }
  }
  
}
  
// MARK: - UICollectionViewDataSource
  
extension MultipleSelectViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return selectedOptions.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    // prepare cell for display
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MultipleSelectCollectionViewCell", for: indexPath) as! MultipleSelectCollectionViewCell
    let item = selectedOptions[indexPath.row]
    
    cell.labelView?.text = item.name
    
    return cell
  }
}

// MARK: - UICollectionViewDelegate
  
extension MultipleSelectViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.itemDeselected(selectedOptions[indexPath.row], identifier: self.identifier)
    
    // data
    selectedOptions.remove(at: indexPath.row)
    
    // collection
    collectionView.deleteItems(at: [indexPath])
    collectionViewHeight.constant = min(collectionView.collectionViewLayout.collectionViewContentSize.height, 300)
    
    // UI refresh
    self.view.layoutIfNeeded()
  }
}
  
// MARK: - UITableViewDataSource
  
extension MultipleSelectViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return options.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // prepare cell for display
    let cell = tableView.dequeueReusableCell(withIdentifier: "MultipleSelectTableViewCell", for: indexPath) as! MultipleSelectTableViewCell
    let item = options[indexPath.row]
    
    cell.labelView?.text = item.name
    
    return cell
  }
}
  
// MARK: - UITableViewDelegate
  
extension MultipleSelectViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated:  true)
    
    // check if already selected
    var itemExists = false
    for item in selectedOptions {
      if item.id == options[indexPath.row].id {
        itemExists = true
        break
      }
    }
    guard !itemExists else { return }
    
    // data
    let cIndexPath = IndexPath(row: selectedOptions.count, section: 0)
    selectedOptions.append(options[indexPath.row])
    
    // add to collection view
    UIView.performWithoutAnimation {
      // collection
      collectionView.insertItems(at: [cIndexPath])
      
      // refresh UI
      collectionViewHeight.constant = min(collectionView.collectionViewLayout.collectionViewContentSize.height, 300)
      self.view.layoutIfNeeded()
    }
    
    // notify delegate
    delegate?.itemSelected(options[indexPath.row], identifier: self.identifier)
  }
}
