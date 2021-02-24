//
//  ViewController.swift
//  Sortify
//
//  Created by Hani Tawil on 26/01/2021.
//

import UIKit

class ViewController: UIViewController, SPTSessionManagerDelegate {
    
    @IBOutlet weak var connectButton: UIButton!
    let SpotifyClientID = "402c24ffa4e14f8d980f51a8f21b01d6"
    let SpotifyRedirectURL = URL(string: "sortify://spotify-login-callback")!
    var accessToken: String? = nil

    lazy var configuration = SPTConfiguration(
      clientID: SpotifyClientID,
      redirectURL: SpotifyRedirectURL
    )
    
    lazy var sessionManager: SPTSessionManager = {
      if let tokenSwapURL = URL(string: "https://sortify-domain.herokuapp.com/api/token"),
         let tokenRefreshURL = URL(string: "https://sortify-domain.herokuapp.com/api/refresh_token") {
        self.configuration.tokenSwapURL = tokenSwapURL
        self.configuration.tokenRefreshURL = tokenRefreshURL
        self.configuration.playURI = ""
      }
      let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
      return manager
    }()
    
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
      print(session)
    }
    
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
      print("fail", error)
    }
    
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
      print("renewed", session)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        connectButton.layer.cornerRadius = 20
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "homeToSorter" {
            let sortPage = segue.destination as! SorterViewController
            
            sortPage.user = sender as? UserDetailsRequest
            sortPage.accessToken = self.accessToken
        }
    }
    
    @IBAction func connectToSpotify(sender: UIButton) {
        let requestedScopes: SPTScope = [.userReadEmail, .userReadPrivate, .userLibraryRead]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    }
    
    func segueToSorter(userDetails: UserDetailsRequest) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "homeToSorter", sender: userDetails)
        }
    }
    
    func getAccessToken(code: String) {
        let url = URL(string: "https://sortify-domain.herokuapp.com/api/token")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        components.queryItems = [
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURL.absoluteString),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        let session = URLSession.shared
                
        let query = components.url!.query
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = Data(query!.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    self.accessToken = "Bearer " + (json["access_token"] as! String)
                    
                    self.getUserProfile()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func getUserProfile() {
        let url = URL(string: "https://api.spotify.com/v1/me")!
        let session = URLSession.shared
        var request = URLRequest(url: url)
        
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
                    let userDetails: UserDetailsRequest = try! JSONDecoder().decode(UserDetailsRequest.self, from: data)
                    
                    self.segueToSorter(userDetails: userDetails)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}
