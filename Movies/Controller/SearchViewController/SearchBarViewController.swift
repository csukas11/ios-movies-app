//
//  SearchViewController.swift
//  Movies
//
//  ViewController responsible for displaying and managing the search bar in the navigation bar.
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

class SearchBarViewController: UIViewController {

  // MARK: - Properties
  
  // Controller
  var searchController = UISearchController(searchResultsController: nil)
  
  // Current search's keyword
  var searchKeyword: String? = nil
  
  // The navigatin bar title
  var navItemTitle: String {
    get { navigationItem.title ?? "" }
    set { navigationItem.title = newValue }
  }
  
  // Placeholder for the search bar
  var searchPlaceholder: String {
    get { searchController.searchBar.placeholder ?? "" }
    set { searchController.searchBar.placeholder = newValue }
  }
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureNavigationBar()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
//    UIView.performWithoutAnimation {
//      searchController.isActive = true
//      searchController.isActive = false
//    }
  }
  
  // Perform the search with the given keyword
  func search(for keyword: String) {}
  
  // Cancel the current search
  func dismissSearch() {}
  
  // MARK: - Helper functions
  
  private func configureNavigationBar() {
    // configure search bar
    searchController.hidesNavigationBarDuringPresentation = true
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    self.navigationItem.searchController = searchController
    self.navigationItem.hidesSearchBarWhenScrolling = true
    // configure title in navbar
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .automatic
    navigationController?.navigationBar.sizeToFit()
  }
  
}

// MARK: - UISearchBarDelegate

extension SearchBarViewController: UISearchBarDelegate {
  // Delay search
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    searchKeyword = searchText
    
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.delayedSearch), object: nil)
    self.perform(#selector(self.delayedSearch), with: nil, afterDelay: 0.75)
  }
  
  // Perform the previously delayed search
  @objc private func delayedSearch() {
    if let keyword = searchKeyword {
      search(for: keyword)
    }
  }
  
  // Handle cancel button
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = ""
    NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(self.delayedSearch), object: nil)

    searchBar.setShowsCancelButton(false, animated: true)
    view.endEditing(true)
    searchKeyword = nil
    dismissSearch()
  }
  
  // Handle search button
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    view.endEditing(true)
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    // always show cancel button while editing
    searchBar.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    // deactivate search bar if empty
    if searchBar.text == "" {
      searchController.isActive = false
      searchBarCancelButtonClicked(searchBar)
    }
  }
}
