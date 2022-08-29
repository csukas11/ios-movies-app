//
//  DiscoverByFilterViewController.swift
//  Movies
//
//  Copyright © 2022. Tamas Csukas. All rights reserved.
//

import UIKit

class DiscoverByFilterViewController: UIViewController {
  
  // The navigatin bar title
  private static let WINDOW_TITLE = "Discover by Filters"
  // Back button title
  private static let BACK_BUTTON_TITLE = "Filters"
  
  // Form options
  private let voteAverageData: [(Int, String)] = [(1, "1"), (2, "2"), (3, "3"), (4, "4"), (5, "5"), (6, "6"), (7, "7"), (8, "8"), (9, "9"), (10, "10")]
  private let minVoteCountData: [(Int, String)] = [(0, "0"), (1, "1"), (100, "100"), (1000, "1.000"), (10000, "10.000"), (100000, "100.000")]
  private let orderByData: [(String, String)] = [
    ("popularity", "Popularity"),
    ("release_date", "Release Date"),
    ("revenue", "Revenue"),
    ("original_title", "Original Title"),
    ("vote_average", "Vote Average"),
    ("vote_count", "Vote Count")
  ]
  
  ///------------------------------------------------------------------
  
  // IBOutlets
  @IBOutlet weak var genresListLabel: UILabel!
  @IBOutlet weak var excludeGenresListLabel: UILabel!
  @IBOutlet weak var peopleListLabel: UILabel!
  @IBOutlet weak var companiesListLabel: UILabel!
  
  @IBOutlet weak var voteAveragePicker1: UIPickerView!
  @IBOutlet weak var voteAveragePicker2: UIPickerView!
  @IBOutlet weak var voteCountPicker: UIPickerView!
  @IBOutlet weak var yearPicker1: UIPickerView!
  @IBOutlet weak var yearPicker2: UIPickerView!
  @IBOutlet weak var runtimeTextField1: UITextField!
  @IBOutlet weak var runtimeTextField2: UITextField!
  @IBOutlet weak var orderByPicker: UIPickerView!
  
  @IBOutlet weak var filterButton: UIButton!
  
  // MARK: - onchange/onclick listeners
  
  @IBAction func onMinRuntime(_ sender: UITextField) {
    if let value = sender.text {
      if !value.isEmpty {
        selectedRuntime = (min: Int(value)!, max: selectedRuntime.max)
      } else {
        selectedRuntime = (min: 0, max: selectedRuntime.max)
      }
    }
  }
  
  @IBAction func onMaxRuntime(_ sender: UITextField) {
    if let value = sender.text {
      if !value.isEmpty {
        selectedRuntime = (min: selectedRuntime.min, max: Int(value)!)
      } else {
        selectedRuntime = (min: selectedRuntime.min, max: 9999)
      }
    }
  }
  
  @IBAction func onOrderByReverse(_ sender: UISwitch) {
    selectedOrderBy = (selectedOrderBy.0, sender.isOn == false ? "desc" : "asc")
  }
  
  @IBAction func onFilter(_ sender: Any) {
  }
  
  // unwind to here
  @IBAction func unwindToDiscoverFilters(_ sender: UIStoryboardSegue) { }
  
  // MARK: - Properties
  
  // State
  private var selectedGenres = [MultipleSelectViewController.ListItem]()
  private var selectedExcludeGenres = [MultipleSelectViewController.ListItem]()
  private var selectedPeople = [MultipleSelectViewController.ListItem]()
  private var selectedCompanies = [MultipleSelectViewController.ListItem]()
  private var selectedVoteAverage = (min: 0, max: 10)
  private var selectedMinVoteCount = 0
  private var selectedReleaseYear = (min: 1900, max: Calendar.current.component(.year, from: Date()))
  private var selectedRuntime = (min: 0, max: 9999)
  private var selectedOrderBy = ("popularity", "desc")
  
  // Fetchers
  var genresFetcher: GenresFetcher?
  var searchPersonFetcher: SearchPersonFetcher?
  var searchCompanyFetcher: SearchCompanyFetcher?
  
  // Current MultipleSelectVC
  private var currentMultipleSelectVC: MultipleSelectViewController?
  
  // MARK: - Funcitons
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // configure title in navbar
    navigationItem.title = DiscoverByFilterViewController.WINDOW_TITLE
    self.navigationController?.navigationBar.prefersLargeTitles = true
    self.navigationItem.largeTitleDisplayMode = .automatic
    
    // Back button
    let backItem = UIBarButtonItem()
    backItem.title = DiscoverByFilterViewController.BACK_BUTTON_TITLE
    navigationItem.backBarButtonItem = backItem
    
    // Set delegates
    voteAveragePicker1.delegate = self
    voteAveragePicker2.delegate = self
    voteCountPicker.delegate = self
    yearPicker1.delegate = self
    yearPicker2.delegate = self
    orderByPicker.delegate = self
    runtimeTextField1.delegate = self
    runtimeTextField2.delegate = self
    
    // Set datasources
    voteAveragePicker1.dataSource = self
    voteAveragePicker2.dataSource = self
    voteCountPicker.dataSource = self
    yearPicker1.dataSource = self
    yearPicker2.dataSource = self
    orderByPicker.dataSource = self
    
    // Filer button
    filterButton.layer.cornerRadius = 6.0
    filterButton.clipsToBounds = true
    
    // Set default values on UI
    voteAveragePicker2.selectRow((voteAverageData.count - 1), inComponent:0, animated:false)
    yearPicker2.selectRow((Calendar.current.component(.year, from: Date()) - 1900), inComponent:0, animated:false)
    runtimeTextField1.text = "0"
    runtimeTextField1.keyboardType = UIKeyboardType.decimalPad
    runtimeTextField2.text = "9999"
    runtimeTextField2.keyboardType = UIKeyboardType.decimalPad
    
    // Keyboard settings
    startAvoidingKeyboard()
    hideKeyboardWhenTappedAround()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let viewController = segue.destination as? MultipleSelectViewController {
      currentMultipleSelectVC = viewController
      
      if segue.identifier == "ToGenresMultipleSelect" {
        viewController.setDelegate(self, identifier: "Genres")
        viewController.addSelectedOptionItems(selectedGenres)
        filterGenres(nil)
      } else if segue.identifier == "ToExcludeGenresMultipleSelect" {
        viewController.setDelegate(self, identifier: "ExcludeGenres")
        viewController.addSelectedOptionItems(selectedExcludeGenres)
        filterGenres(nil)
      } else if segue.identifier == "ToPeopleMultipleSelect" {
        viewController.setDelegate(self, identifier: "People")
        viewController.addSelectedOptionItems(selectedPeople)
        filterPeople(nil)
      } else if segue.identifier == "ToCompaniesMultipleSelect" {
        viewController.setDelegate(self, identifier: "Companies")
        viewController.addSelectedOptionItems(selectedCompanies)
        filterCompanies(nil)
      }
    }
    if let viewController = segue.destination as? DiscoverByFilterResultsViewController {
      viewController.setFilters(
        genres: selectedGenres.map{ $0.id },
        excludeGenres: selectedExcludeGenres.map{ $0.id },
        people: selectedPeople.map{ $0.id },
        companies: selectedCompanies.map{ $0.id },
        voteAverage: selectedVoteAverage,
        minVoteCount: selectedMinVoteCount,
        releaseYear: selectedReleaseYear,
        runtime: selectedRuntime,
        sortBy: "\(selectedOrderBy.0).\(selectedOrderBy.1)")
    }
  }
  
  // MARK: - fetchers
  
  func filterGenres(_ query: String?) {
    guard let viewController = currentMultipleSelectVC else { return }
    
    viewController.clearOptionItems()
    
    genresFetcher?.fetch() { [weak viewController] response, error in
      if let response = response {
        for item in response {
          if let query = query, !query.isEmpty {
            if !item.name.lowercased().contains(query.lowercased()) {
              continue
            }
          }
          
          viewController?.addOptionItem(MultipleSelectViewController.ListItem(id: item.id, name: item.name))
        }
      }
    }
  }
    
  func filterPeople(_ query: String?) {
    guard let viewController = currentMultipleSelectVC else { return }
    
    viewController.clearOptionItems()
    
    let query = query ?? ""
    searchPersonFetcher?.fetch(for: query, page: 1) { [weak viewController] response, error in
      if let response = response {
        for item in response.results {
          viewController?.addOptionItem(MultipleSelectViewController.ListItem(id: item.id, name: item.name))
        }
      }
    }
  }
    
  func filterCompanies(_ query: String?) {
    guard let viewController = currentMultipleSelectVC else { return }
    
    viewController.clearOptionItems()
    
    let query = query ?? ""
    searchCompanyFetcher?.fetch(for: query, page: 1) { [weak viewController] response, error in
      if let response = response {
        for item in response.results {
          viewController?.addOptionItem(MultipleSelectViewController.ListItem(id: item.id, name: item.name))
        }
      }
    }
  }
  
}
  
// MARK: - UIPickerViewDataSource

extension DiscoverByFilterViewController: UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    switch pickerView.tag {
    case 0...1:
      return voteAverageData.count
    case 2:
      return minVoteCountData.count
    case 3...4:
      return Calendar.current.component(.year, from: Date()) - 1900 + 1
    case 5:
      return orderByData.count
    default:
      return 0
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    switch pickerView.tag {
    case 0...1:
      return voteAverageData[row].1
    case 2:
      return minVoteCountData[row].1
    case 3...4:
      return String(1900 + row)
    case 5:
      return orderByData[row].1
    default:
      return ""
    }
  }
  
}
  
  // MARK: - UIPickerViewDelegate
  
extension DiscoverByFilterViewController: UIPickerViewDelegate {
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    switch pickerView.tag {
    case 0:
      selectedVoteAverage = (min: voteAverageData[row].0, max: selectedVoteAverage.max)
    case 1:
      selectedVoteAverage = (min: selectedVoteAverage.min, max: voteAverageData[row].0)
    case 2:
      selectedMinVoteCount = minVoteCountData[row].0
    case 3:
      selectedReleaseYear = (min: 1900 + row, max: selectedReleaseYear.max)
    case 4:
      selectedReleaseYear = (min: selectedReleaseYear.min, max: 1900 + row)
    case 5:
      selectedOrderBy = (orderByData[row].0, selectedOrderBy.1)
    default: break
    }
  }
  
  func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
    var label = UILabel()
    if let v = view as? UILabel { label = v }
    label.font = UIFont (name: "System", size: 15)
    label.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
    label.textAlignment = .center
    return label
  }

}

// MARK: - UITextFieldDelegate

extension DiscoverByFilterViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let allowedCharacters = CharacterSet.decimalDigits
    let characterSet = CharacterSet(charactersIn: string)
    
    return allowedCharacters.isSuperset(of: characterSet)
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      self.view.endEditing(true)
      return false
  }

}
  
  // MARK: - MultipleSelectDelegate

extension DiscoverByFilterViewController: MultipleSelectDelegate {
  
  func itemSelected(_ item: MultipleSelectViewController.ListItem, identifier: String) {
    if identifier == "Genres" {
      selectedGenres.append(item)
      genresListLabel.text = selectedGenres.map({ item in item.name }).joined(separator: ", ")
    } else if identifier == "ExcludeGenres" {
      selectedExcludeGenres.append(item)
      excludeGenresListLabel.text = selectedExcludeGenres.map({ item in item.name }).joined(separator: ", ")
    } else if identifier == "People" {
      selectedPeople.append(item)
      peopleListLabel.text = selectedPeople.map({ item in item.name }).joined(separator: ", ")
    } else if identifier == "Companies" {
      selectedCompanies.append(item)
      companiesListLabel.text = selectedCompanies.map({ item in item.name }).joined(separator: ", ")
    }
  }
  
  func itemDeselected(_ item: MultipleSelectViewController.ListItem, identifier: String) {
    if identifier == "Genres" {
      selectedGenres = selectedGenres.filter() { item2 in item.id != item2.id }
      if selectedGenres.count > 0 {
        genresListLabel.text = selectedGenres.map({ item in item.name }).joined(separator: ", ")
      } else {
        genresListLabel.text = "Select genres..."
      }
    } else if identifier == "ExcludeGenres" {
      selectedExcludeGenres = selectedExcludeGenres.filter() { item2 in item.id != item2.id }
      if selectedExcludeGenres.count > 0 {
        excludeGenresListLabel.text = selectedExcludeGenres.map({ item in item.name }).joined(separator: ", ")
      } else {
        excludeGenresListLabel.text = "Select genres..."
      }
    } else if identifier == "People" {
      selectedPeople = selectedPeople.filter() { item2 in item.id != item2.id }
      if selectedPeople.count > 0 {
        peopleListLabel.text = selectedPeople.map({ item in item.name }).joined(separator: ", ")
      } else {
        peopleListLabel.text = "Select people..."
      }
    } else if identifier == "Companies" {
      selectedCompanies = selectedCompanies.filter() { item2 in item.id != item2.id }
      if selectedCompanies.count > 0 {
        companiesListLabel.text = selectedCompanies.map({ item in item.name }).joined(separator: ", ")
      } else {
        companiesListLabel.text = "Select companies..."
      }
    }
  }
  
  func filterItems(_ query: String?, identifier: String) {
    if identifier == "Genres" {
      filterGenres(query)
    } else if identifier == "ExcludeGenres" {
      filterGenres(query)
    } else if identifier == "People" {
      filterPeople(query)
    } else if identifier == "Companies" {
      filterCompanies(query)
    }
  }

}
