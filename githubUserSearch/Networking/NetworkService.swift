//
//  NetworkService.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import Foundation

class NetworkService {
    
    typealias SuccessBlock = ((Data) -> Void)?
    typealias FailureBlock = ((String?) -> Void)?
    
    static let sharedManager: NetworkService = {
        let instance = NetworkService()
        return instance
    }()
    
    private let baseUrl = "https://api.github.com/search/users"
    
    func search(user term: String, onSuccess success: SuccessBlock, onFailure failure: FailureBlock) {
        
        guard let queryString = "q=\(term)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseUrl)?\(queryString)") else {
            failure?("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in

            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType,
                  mimeType.hasSuffix("json"),
                  let data = data,
                  error == nil else {
                var failureReason: String? = nil
                if let error = error {
                    failureReason = error.localizedDescription
                } else {
                    failureReason = "Server response unrecognized"
                }
                failure?(failureReason)
                return
            }
            
            print("Search completed succesfully!")
            
            success?(data)
            
        }.resume()
    }
}
