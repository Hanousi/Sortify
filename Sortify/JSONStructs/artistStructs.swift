//
//  artistStructs.swift
//  Sortify
//
//  Created by Hani Tawil on 15/02/2021.
//

import Foundation

// MARK: - ArtistsRequest
struct ArtistsRequest: Codable {
    let artists: [Artists]
}

// MARK: - Artist
struct Artists: Codable {
    let genres: [String]
    let href: String
    let id: String
    let name: String
    let popularity: Int
    let type, uri: String

    enum CodingKeys: String, CodingKey {
        case genres, href, id, name, popularity, type, uri
    }
}
