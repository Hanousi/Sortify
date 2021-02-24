//
//  ArtistSelectorController.swift
//  Sortify
//
//  Created by Hani Tawil on 22/02/2021.
//

import UIKit

class ArtistSelectorController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var artists: [Artists] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtistCell", for: indexPath)
        let artist = artists[indexPath.row]
        cell.textLabel?.text = artist.name
        return cell
    }
}
