//
//  UIImageView+Network.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode

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
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse,
                  httpURLResponse.statusCode == 200,
                  let mimeType = response?.mimeType,
                  mimeType.hasPrefix("image"),
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async { [weak self] in
                    // remove ai
                    activityIndicator.stopAnimating()
                    NSLayoutConstraint.deactivate(activityConstraints)
                    activityIndicator.removeFromSuperview()
                    
                    self?.image = #imageLiteral(resourceName: "placeholder")
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
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
