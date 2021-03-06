//
//  SorterViewController.swift
//  Sortify
//
//  Created by Hani Tawil on 06/02/2021.
//

import UIKit
import SDWebImage

class SorterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var greetLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var playlistNameField: UITextField!
    
    var user: UserDetailsRequest? = nil
    var accessToken: String? = nil
    var savedTracks: [Item] = []
    var savedArtists: [Artists] = []
    var selectedArtists: Set<Artists> = []
    var savedGenres: [String] = []
    var selectedGenres: Set<String> = []
    var savedFeatures: [AudioFeature] = []
    var selectedTracks: Set<Track> = []
    
    let semaphore = DispatchSemaphore(value: 1)

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        greetLabel.text = "Hello " + user!.display_name + "!"
        createButton.layer.cornerRadius = 20
        
        tableView.rowHeight = 90.00
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        collectAllData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GenreSelector" {
            let genreSelector = segue.destination as! GenreSelectorController
            genreSelector.selectedGenres = self.selectedGenres
            
            genreSelector.callback = { result in
                self.selectedGenres = result
                
                self.updateSelectedSongs()
            }
            
            genreSelector.genres = self.savedGenres.sorted()
        } else if segue.identifier == "ArtistSelector" {
            let artistSelector = segue.destination as! ArtistSelectorController
            artistSelector.selectedArtists = self.selectedArtists
            
            artistSelector.callback = { result in
                self.selectedArtists = result
                
                self.updateSelectedSongs()
            }
            
            artistSelector.artists = self.savedArtists.sorted(by: { (a, b) -> Bool in
                a.name < b.name
            })
        }
    }
    
    func collectAllData() {
        getTotalTracks()
    }
    
    func timeToWork() {
        print("Wasssaaaapppp")
    }
    
    @IBAction func createPlaylist(_ sender: Any) {
        //MARK: Catch empty selected songs
        createPlaylist()
    }
    
    func updateSelectedSongs() {
        if !self.selectedArtists.isEmpty || !self.selectedGenres.isEmpty {
            for item in self.savedTracks {
                if let trackGenres = item.track.genres {
                    if trackGenres.containsOneOf(members: Array(self.selectedGenres)) {
                        self.selectedTracks.insert(item.track)
                        continue
                    }
                }
                
                for artist in item.track.artists {
                    if (Array(self.selectedArtists).getByID(id: artist.id) != nil) {
                        self.selectedTracks.insert(item.track)
                        continue
                    }
                }
            }
        } else {
            self.selectedTracks = []
        }
        
        tableView.reloadData()
    }
    
    func handleArtists(mainGroup: DispatchGroup) {
        for artist in self.savedArtists {
            self.savedGenres.append(contentsOf: artist.genres)
        }
        
        self.savedGenres = Array(Set(self.savedGenres))
        
        self.semaphore.wait()
        
        for (index, element) in self.savedTracks.enumerated() {
            for artist in element.track.artists {
                if let thisArtist = self.savedArtists.getByID(id: artist.id) {
                    if (self.savedTracks[index].track.genres == nil) {
                        self.savedTracks[index].track.genres = []
                    }

                    self.savedTracks[index].track.genres!.insertAll(contentsof: thisArtist.genres)
                }
            }
        }
        
        print("Genres Handled")
        self.semaphore.signal()
        mainGroup.leave()
    }
    
    func handleFeatures(mainGroup: DispatchGroup) {
        
        self.semaphore.wait()

        for (index, element) in self.savedTracks.enumerated() {
            for feature in self.savedFeatures {
                if element.track.id == feature.id {
                    self.savedTracks[index].track.features = feature
                }
            }
        }
        
        print("Features handled")
        self.semaphore.signal()
        mainGroup.leave()
    }
    
    func getArtists(mainGroup: DispatchGroup) {
        let artistIds = Array(Set(pullArtistIds()))
        let group = DispatchGroup()
        
        var lastMax = 0
        mainGroup.enter()
        
        for x in stride(from: 50, to: artistIds.count, by: 50) {
            group.enter()
            let artistURIs = artistIds[(x-50)...(x-1)].joined(separator: ",")
            lastMax = x
            
            getArtistsWithIDs(ids: artistURIs, group: group)
        }
                
        //Stride doesnt get to the final multiple of 50. Making final call here
        group.enter()
        getArtistsWithIDs(ids: artistIds[lastMax...(artistIds.count - 1)].joined(separator: ","), group: group)
        
        group.notify(queue: .main, execute: {
            self.handleArtists(mainGroup: mainGroup)
        })
    }
    
    func getFeatures(mainGroup: DispatchGroup) {
        let trackIds = Array(Set(pullTrackIds()))
        let group = DispatchGroup()
        
        var lastMax = 0
        mainGroup.enter()
        
        for x in stride(from: 100, to: trackIds.count, by: 100) {
            group.enter()
            let trackURIs = trackIds[(x-100)...(x-1)].joined(separator: ",")
            lastMax = x
            
            getFeaturesWithIDs(ids: trackURIs, group: group)
        }
        
        //Stride doesnt get to the final multiple of 50. Making final call here
        group.enter()
        getFeaturesWithIDs(ids: trackIds[lastMax...(trackIds.count - 1)].joined(separator: ","), group: group)
        
        group.notify(queue: .main, execute: {
            self.handleFeatures(mainGroup: mainGroup)
        })
    }
    
    func getArtistsAndFeatures() {
        let group = DispatchGroup()
        
        getArtists(mainGroup: group)
        getFeatures(mainGroup: group)
        
        group.notify(queue: .main, execute: timeToWork)
    }
    
    func pullArtistIds() -> [String] {
        var ids: [String] = []
        
        for item in self.savedTracks {
            for artist in item.track.artists {
                ids.append(artist.id)
            }
        }
                
        return ids
    }
    
    func pullTrackIds() -> [String] {
        var ids: [String] = []
        
        for item in self.savedTracks {
            ids.append(item.track.id)
        }
                
        return ids
    }
    
    func getAllTracks(total: Int){
        let offsetsLeft = (total/50)
        let group = DispatchGroup()
        
        for offset in 1...offsetsLeft {
            group.enter()
            
            self.getSavedTracks(offset: offset * 50, group: group)
        }
        
        group.notify(queue: .main, execute: getArtistsAndFeatures)
    }
    
    //MARK: Table funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(self.selectedTracks.count)
        
        return self.selectedTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SelectedCell", for: indexPath) as! selectedTrackCell
        let thisTrack = Array(self.selectedTracks)[indexPath.row]
        
        cell.trackImage.load(url: URL(string: thisTrack.album.images[0].url)!)
        cell.trackTitleLabel.text = thisTrack.name
        cell.trackArtists.text = thisTrack.stringifyArtists()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTracks.remove(Array(self.selectedTracks)[indexPath.row])
        print(111111)
        
        tableView.reloadData()
    }
    
    //MARK: HTTP Calls
    func getTotalTracks() {
        print("Getting Total tracks")
        let url = URL(string: "https://api.spotify.com/v1/me/tracks")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "offset", value: "0"),
        ]
        
        let session = URLSession.shared
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(self.accessToken!, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if (try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) != nil {
                    
                    let result = try! JSONDecoder().decode(SavedTracks.self, from: data)
                    self.savedTracks.append(contentsOf: result.items)
                    
                    self.getAllTracks(total: result.total)
                    
                    print("Total Tracks are: " + String(result.total))
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func createPlaylist() {
        let url = URL(string: "https://api.spotify.com/v1/users/" + self.user!.id + "/playlists")!
        //MARK: Catch empty text field
        let createPlaylistBody: [String: Any] = ["name": "Sortify: " + self.playlistNameField.text!]
        let jsonData = try? JSONSerialization.data(withJSONObject: createPlaylistBody)

        let session = URLSession.shared
                                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(self.accessToken!, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if (try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) != nil {
                    let playlistRequest: PlaylistRequest = try! JSONDecoder().decode(PlaylistRequest.self, from: data)

                    print("Playlist created")
                    
                    self.addSongsToNewPlaylist(id: playlistRequest.id)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func addSongsToNewPlaylist(id: String) {
        let url = URL(string: "https://api.spotify.com/v1/playlists/" + id + "/tracks")!
        let createPlaylistBody: [String: Any] = ["uris": self.selectedTracks.getTrackURIs()]
        let jsonData = try? JSONSerialization.data(withJSONObject: createPlaylistBody)

        let session = URLSession.shared
                                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(self.accessToken!, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if (try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) != nil {
                    
                    print("Items added")
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func getSavedTracks(offset: Int, group: DispatchGroup) {
        let url = URL(string: "https://api.spotify.com/v1/me/tracks")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "limit", value: "50"),
            URLQueryItem(name: "offset", value: String(offset)),
        ]
        
        let session = URLSession.shared
                                
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(self.accessToken!, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }
            
            defer {
                group.leave()
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if (try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) != nil {
                    
                    let result = try! JSONDecoder().decode(SavedTracks.self, from: data)
                    self.savedTracks.append(contentsOf: result.items)
                    
                    print("Recieved offset: " + String(offset))
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func getArtistsWithIDs(ids: String, group: DispatchGroup) {
        let url = URL(string: "https://api.spotify.com/v1/artists")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "ids", value: ids),
        ]
        
        let session = URLSession.shared
                                
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(self.accessToken!, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }
            
            defer {
                group.leave()
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if (try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) != nil {
                    
                    let result = try! JSONDecoder().decode(ArtistsRequest.self, from: data)
                    self.savedArtists.append(contentsOf: result.artists)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func getFeaturesWithIDs(ids: String, group: DispatchGroup) {
        let url = URL(string: "https://api.spotify.com/v1/audio-features")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "ids", value: ids),
        ]
        
        let session = URLSession.shared
                                
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue(self.accessToken!, forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }
            
            defer {
                group.leave()
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if (try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) != nil {
                    
                    let result = try! JSONDecoder().decode(FeaturesRequest.self, from: data)
                    self.savedFeatures.append(contentsOf: result.audioFeatures)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
}
