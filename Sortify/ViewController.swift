//
//  ViewController.swift
//  Sortify
//
//  Created by Hani Tawil on 26/01/2021.
//

import UIKit

class ViewController: UIViewController, SPTSessionManagerDelegate {
    
    let SpotifyClientID = "402c24ffa4e14f8d980f51a8f21b01d6"
    let SpotifyRedirectURL = URL(string: "sortify://spotify-login-callback")!

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
        // Do any additional setup after loading the view.
    }
    
    @IBAction func connectToSpotify(sender: UIButton) {
        print(222222)
        let requestedScopes: SPTScope = [.userReadEmail, .userReadPrivate]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    }
}
