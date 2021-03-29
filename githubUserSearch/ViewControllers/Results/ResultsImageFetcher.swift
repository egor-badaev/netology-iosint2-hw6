//
//  ResultsImageFetcher.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 23.03.2021.
//

import UIKit

class ResultsImageFetcher {
    
    static let shared: ResultsImageFetcher = {
        let instance = ResultsImageFetcher()
        return instance
    }()
    
    // MARK: - Private properties
    
    private var dataTasks: [Int: URLSessionDataTask] = [:]
    private var fetchedImages: [Int: UIImage] = [:]
    
    // MARK: -
    private init() { }
    
    // MARK: - Public methods
    
    func fetchAsync(from urlString: String, for identifier: Int, completion: ((Result<UIImage,Error>) -> Void)?) {
        
        guard let url = URL(string: urlString) else {
            completion?(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType,
                  mimeType.hasPrefix("image"),
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                completion?(.failure(NetworkError.badResponse))
                return
            }

            completion?(.success(image))

            guard let self = self else { return }
            self.dataTasks.removeValue(forKey: identifier)
            self.fetchedImages[identifier] = image
        }
        
        dataTasks[identifier] = task
        task.resume()
    }
    
    func fetchAsync(from urlString: String, for identifier: Int) {
        guard fetchedImages[identifier] == nil else { return }
        fetchAsync(from: urlString, for: identifier, completion: nil)
    }
    
    func fetchedImage(for identifier: Int) -> UIImage? {
        return fetchedImages[identifier]
    }
    
    func calcelFetch(for identifier: Int) {
        guard let task = dataTasks[identifier] else {
            print("Warning: trying to cancel non-existent data task (id \(identifier))")
            return
        }
        task.cancel()
    }
}
