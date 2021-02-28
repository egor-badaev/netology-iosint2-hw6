//
//  ResultsCollectionViewHeader.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 27.02.2021.
//

import UIKit

class ResultsCollectionViewHeader: UICollectionReusableView {

    // MARK : - Properties
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    private let infoLabel: UILabel = {
        $0.toAutoLayout()
        $0.font = .systemFont(ofSize: 17, weight: .bold)
        return $0
    }(UILabel())
    
    // MARK: - Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        print(type(of: self), #function)
        
        addSubview(infoLabel)
        
        let constraints = [
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: AppSettings.collectionInsets.top),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSettings.collectionInsets.left),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSettings.collectionInsets.right),
            infoLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func updateTimer(with seconds: Int) {
        infoLabel.text = "Data reload in \(seconds) s"
    }
}
