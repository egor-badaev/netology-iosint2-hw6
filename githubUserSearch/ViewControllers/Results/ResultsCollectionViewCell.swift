//
//  ResultsCollectionViewCell.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import UIKit

class ResultsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    var representedIdentifier: Int = 0
    
    private var avatarImageView: UIImageView = {
        $0.toAutoLayout()
        $0.contentMode = .scaleAspectFit
        return $0
    }(UIImageView())
    
    private let nameLabel: UILabel = {
        $0.toAutoLayout()
        $0.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        $0.font = .systemFont(ofSize: 14.0, weight: .medium)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(avatarImageView)
        self.addSubview(nameLabel)
        self.addSubview(activityIndicator)
        
        let constraints = [
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: AppSettings.padding),
            avatarImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 132),
            avatarImageView.heightAnchor.constraint(equalTo: avatarImageView.widthAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: AppSettings.spacing),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSettings.padding),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSettings.padding),
            nameLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -AppSettings.padding),
            activityIndicator.centerXAnchor.constraint(equalTo: avatarImageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: avatarImageView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        showActivity()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public functions
    
    func configure(withName name: String, avatar: UIImage, identifier: Int) {
        representedIdentifier = identifier
        nameLabel.text = name
        avatarImageView.image = avatar
        hideActivity()
    }
    
    func resetData() {
        nameLabel.text = nil
        avatarImageView.image = nil
        showActivity()
    }
    
    // MARK: - Private functions
    
    private func showActivity() {
        guard !activityIndicator.isAnimating else { return }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideActivity() {
        guard activityIndicator.isAnimating else { return }
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
