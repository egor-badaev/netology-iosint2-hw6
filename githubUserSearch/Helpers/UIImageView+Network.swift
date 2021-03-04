//
//  UIImageView+Network.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) -> URLSessionDataTask? {
        contentMode = mode
        
        guard self.image == nil else { return nil }

        // Put activity indicator while image is being loaded
        let activityIndicator = UIActivityIndicatorView(frame: self.bounds)
        activityIndicator.style = .medium
        activityIndicator.toAutoLayout()
        self.addSubview(activityIndicator)
        let activityConstraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        NSLayoutConstraint.activate(activityConstraints)
        activityIndicator.startAnimating()

        // download image
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType,
                  mimeType.hasPrefix("image"),
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    // remove ai
                    activityIndicator.stopAnimating()
                    NSLayoutConstraint.deactivate(activityConstraints)
                    activityIndicator.removeFromSuperview()
                    
                    // TODO: set placeholder image
                }
                return
            }
            DispatchQueue.main.async() { [weak self] in
                // remove ai
                activityIndicator.stopAnimating()
                NSLayoutConstraint.deactivate(activityConstraints)
                activityIndicator.removeFromSuperview()
                
                // set image
                self?.image = image
            }
        }
        task.resume()
        return task
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) -> URLSessionDataTask? {
        guard let url = URL(string: link) else { return nil }
        return downloaded(from: url, contentMode: mode)
    }
}
