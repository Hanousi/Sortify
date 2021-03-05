//
//  GenreSelectorController.swift
//  Sortify
//
//  Created by Hani Tawil on 22/02/2021.
//

import UIKit

class GenreSelectorController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var genres: [String] = []
    var filteredGenres: [String] = []
    var callback: ((Set<String>)->())?
    var selectedGenres: Set<String> = []
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet var searchContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    func getGenreByIndexPath(indexPath: IndexPath) -> String {
        if isFiltering {
            return filteredGenres[indexPath.row]
        } else {
            return genres[indexPath.row]
        }
    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    override func viewDidLoad() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        searchContainer.addSubview(searchController.searchBar)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Filter Genres"
        definesPresentationContext = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callback?(self.selectedGenres)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            tableView.contentInset = .zero
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        tableView.scrollIndicatorInsets = tableView.contentInset
    }
            
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
      if isFiltering {
        return filteredGenres.count
      }
        
      return genres.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let genre = getGenreByIndexPath(indexPath: indexPath)
        
        if self.selectedGenres.contains(genre) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
        
        cell.textLabel?.text = genre.capitalized
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedGenres.insert(getGenreByIndexPath(indexPath: indexPath))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedGenres.remove(getGenreByIndexPath(indexPath: indexPath))
    }
    
    func filterContentForSearchText(_ searchText: String) {
      filteredGenres = genres.filter { (genre: String) -> Bool in
        return genre.lowercased().contains(searchText.lowercased())
      }
      
      tableView.reloadData()
    }
}

extension GenreSelectorController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}
