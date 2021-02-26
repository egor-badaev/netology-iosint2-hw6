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
    private var avatarImage: UIImageView = {
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
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        self.addSubview(avatarImage)
        self.addSubview(nameLabel)
        
        let constraints = [
            avatarImage.topAnchor.constraint(equalTo: topAnchor, constant: AppSettings.padding),
            avatarImage.centerXAnchor.constraint(equalTo: centerXAnchor),
            avatarImage.widthAnchor.constraint(equalToConstant: 132),
            avatarImage.heightAnchor.constraint(equalTo: avatarImage.widthAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImage.bottomAnchor, constant: AppSettings.spacing),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSettings.padding),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSettings.padding),
            nameLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -AppSettings.padding)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public functions
    
    func configure(withName name: String, avatarUrl: String) {
        nameLabel.text = name
        avatarImage.downloaded(from: avatarUrl)
    }
}
