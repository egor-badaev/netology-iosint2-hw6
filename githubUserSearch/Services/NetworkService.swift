//
//  NetworkService.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import Foundation
import SwiftyJSON

class NetworkService {
    
    static let sharedManager: NetworkService = {
        let instance = NetworkService()
        return instance
    }()
    
    private let baseUrl = "https://api.github.com/search/users"
    private var fetchInProgress = false
    
    private init() {
        
    }
    
    func search(user term: String, onCompletion completion: @escaping (Result<JSON, Error>) -> Void) {
        
        guard !fetchInProgress else {
            return
        }

        guard let queryString = "q=\(term)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseUrl)?\(queryString)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        fetchInProgress = true

        URLSession.shared.dataTask(with: url) { data, response, error in

            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType,
                  mimeType.hasSuffix("json"),
                  let data = data else {
                self.fetchInProgress = false
                completion(.failure(NetworkError.badResponse))
                return
            }
            
            print("Search completed succesfully!")
            self.fetchInProgress = false
            
            guard let json = try? JSON(data: data) else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            completion(.success(json))
            
        }.resume()
    }
}
