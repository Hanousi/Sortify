//
//  NetworkManager.swift
//  Sortify
//
//  Created by Hani Tawil on 15/09/2024.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func performRequest<T: Decodable>(
        url: URL,
        httpMethod: String = "GET",
        httpBody: Data? = nil,
        headers: [String: String]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.httpBody = httpBody
        headers?.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    // Used for non-decodable requests
    func performRequest(
            url: URL,
            httpMethod: String = "GET",
            httpBody: Data? = nil,
            headers: [String: String]? = nil,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            var request = URLRequest(url: url)
            request.httpMethod = httpMethod
            request.httpBody = httpBody
            headers?.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(()))
            }
            task.resume()
        }
}
