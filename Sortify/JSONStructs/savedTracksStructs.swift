// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let savedTracks = try? newJSONDecoder().decode(SavedTracks.self, from: jsonData)

import Foundation

// MARK: - SavedTracks
struct SavedTracks: Codable {
    let href: String
    var items: [Item]
    let limit: Int
    let offset: Int
    let total: Int
}

// MARK: - Item
struct Item: Codable {
    var track: Track

    enum CodingKeys: String, CodingKey {
        case track
    }
}

// MARK: - Track
struct Track: Codable {
    let album: Album
    let artists: [Artist]
    let availableMarkets: [String]
    let discNumber, durationMS: Int
    let explicit: Bool
    let externalIDS: ExternalIDS
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let isLocal: Bool
    let name: String
    let popularity: Int
    let previewURL: String?
    let trackNumber: Int
    let type: TrackType
    let uri: String
    var features: AudioFeature?
    var genres: [String]?

    enum CodingKeys: String, CodingKey {
        case album, artists
        case availableMarkets = "available_markets"
        case discNumber = "disc_number"
        case durationMS = "duration_ms"
        case explicit
        case externalIDS = "external_ids"
        case externalUrls = "external_urls"
        case href, id
        case isLocal = "is_local"
        case name, popularity
        case previewURL = "preview_url"
        case trackNumber = "track_number"
        case type, uri, features, genres
    }
}

// MARK: - Album
struct Album: Codable {
    let albumType: AlbumTypeEnum
    let artists: [Artist]
    let availableMarkets: [String]
    let externalUrls: ExternalUrls
    let href: String
    let id: String
    let images: [Image]
    let name: String
    let totalTracks: Int
    let type: AlbumTypeEnum
    let uri: String

    enum CodingKeys: String, CodingKey {
        case albumType = "album_type"
        case artists
        case availableMarkets = "available_markets"
        case externalUrls = "external_urls"
        case href, id, images, name
        case totalTracks = "total_tracks"
        case type, uri
    }
}

enum AlbumTypeEnum: String, Codable {
    case album = "album"
    case compilation = "compilation"
    case single = "single"
}

// MARK: - Artist
struct Artist: Codable {
    let externalUrls: ExternalUrls
    let href: String
    let id, name: String
    let type: ArtistType
    let uri: String

    enum CodingKeys: String, CodingKey {
        case externalUrls = "external_urls"
        case href, id, name, type, uri
    }
}

// MARK: - ExternalUrls
struct ExternalUrls: Codable {
    let spotify: String
}

// MARK: - Features
struct Features: Codable {
    let danceability, energy: Double
    let key: Int
    let loudness: Double
    let mode: Int
    let speechiness, acousticness, instrumentalness, liveness: Double
    let valence, tempo: Double
    let type, id, uri: String
    let trackHref: String
    let analysisURL: String
    let durationMS, timeSignature: Int

    enum CodingKeys: String, CodingKey {
        case danceability, energy, key, loudness, mode, speechiness, acousticness, instrumentalness, liveness, valence, tempo, type, id, uri
        case trackHref = "track_href"
        case analysisURL = "analysis_url"
        case durationMS = "duration_ms"
        case timeSignature = "time_signature"
    }
}

enum ArtistType: String, Codable {
    case artist = "artist"
}

// MARK: - Image
struct Image: Codable {
    let height: Int
    let url: String
    let width: Int
}

// MARK: - ExternalIDS
struct ExternalIDS: Codable {
    let isrc: String
}

enum TrackType: String, Codable {
    case track = "track"
}
