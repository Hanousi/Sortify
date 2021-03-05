//
//  ArtistSelectorController.swift
//  Sortify
//
//  Created by Hani Tawil on 22/02/2021.
//

import UIKit

class ArtistSelectorController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var artists: [Artists] = []
    var selectedArtists: Set<Artists> = []
    var filteredArtists: [Artists] = []
    let searchController = UISearchController(searchResultsController: nil)
    var callback: ((Set<Artists>)->())?


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchContainer: UIView!
    
    func getArtistByIndexPath(indexPath: IndexPath) -> Artists {
        if isFiltering {
            return filteredArtists[indexPath.row]
        } else {
            return artists[indexPath.row]
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
        searchController.searchBar.placeholder = "Filter Artists"
        definesPresentationContext = true
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
    
    override func viewWillDisappear(_ animated: Bool) {
        callback?(self.selectedArtists)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
          return filteredArtists.count
        }
          
        return artists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath)
        let artist = getArtistByIndexPath(indexPath: indexPath)
        
        if self.selectedArtists.contains(artist) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        }
        
        cell.textLabel?.text = artist.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedArtists.insert(getArtistByIndexPath(indexPath: indexPath))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedArtists.remove(getArtistByIndexPath(indexPath: indexPath))
    }
    
    func filterContentForSearchText(_ searchText: String) {
      filteredArtists = artists.filter { (artist: Artists) -> Bool in
        return artist.name.lowercased().contains(searchText.lowercased())
      }
    
      tableView.reloadData()
    }
}

extension ArtistSelectorController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    let searchBar = searchController.searchBar
    filterContentForSearchText(searchBar.text!)
  }
}
