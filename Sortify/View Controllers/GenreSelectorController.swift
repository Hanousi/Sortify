//
//  GenreSelectorController.swift
//  Sortify
//
//  Created by Hani Tawil on 22/02/2021.
//

import UIKit

class GenreSelectorController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var genres: [String] = []
    @IBOutlet weak var mytable: UITableView!
            
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let genre = genres[indexPath.row]
        cell.textLabel?.text = genre.capitalized
        return cell
    }
}

