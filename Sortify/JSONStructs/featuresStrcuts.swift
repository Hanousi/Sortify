//
//  featuresStrcuts.swift
//  Sortify
//
//  Created by Hani Tawil on 18/02/2021.
//

import Foundation

// MARK: - FeaturesRequest
struct FeaturesRequest: Codable {
    let audioFeatures: [AudioFeature]

    enum CodingKeys: String, CodingKey {
        case audioFeatures = "audio_features"
    }
}

// MARK: - AudioFeature
struct AudioFeature: Codable {
    let danceability, energy: Double
    let key: Int
    let loudness: Double
    let mode: Int
    let speechiness, acousticness, instrumentalness, liveness: Double
    let valence, tempo: Double
    let type, id, uri: String
    let trackHref, analysisURL: String
    let durationMS, timeSignature: Int

    enum CodingKeys: String, CodingKey {
        case danceability, energy, key, loudness, mode, speechiness, acousticness, instrumentalness, liveness, valence, tempo, type, id, uri
        case trackHref = "track_href"
        case analysisURL = "analysis_url"
        case durationMS = "duration_ms"
        case timeSignature = "time_signature"
    }
}
