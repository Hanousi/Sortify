//
//  JSONStructs.swift
//  Sortify
//
//  Created by Hani Tawil on 29/01/2021.
//

import Foundation

//MARK: - UserDetails

struct UserDetailsRequest: Decodable {
    enum Category: String, Decodable {
        case swift, combine, debugging, xcode
    }
    
    let display_name: String
}
