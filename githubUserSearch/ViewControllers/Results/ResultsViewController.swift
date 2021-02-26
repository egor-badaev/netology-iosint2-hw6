//
//  ResultsViewController.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import UIKit
import SwiftyJSON

class ResultsViewController: UIViewController {
    
    // MARK: - Properties
    
    var term: String
    var results: Results?
    
    private let activityIndicator: UIActivityIndicatorView = {
        $0.toAutoLayout()
        $0.style = .large
        return $0
    }(UIActivityIndicatorView())
    
    private lazy var collectionView: UICollectionView = {
        
        let collectionViewFlowLayout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        
        collectionView.toAutoLayout()
        collectionView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        collectionView.register(ResultsCollectionViewCell.self, forCellWithReuseIdentifier: ResultsCollectionViewCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Hide view while loading data
        collectionView.isHidden = true
        
        return collectionView
    }()

    
    // MARK: - Life cycle
    
    init(_ term: String) {
        self.term = term
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchData()
    }
    
    // MARK: - Private methods
    
    private func setupUI() {
        view.backgroundColor = .white
        self.title = "Search results for \"\(term)\""
        
        view.addSubview(activityIndicator)
        view.addSubview(collectionView)
        
        let constraints = [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func fetchData() {
        activityIndicator.startAnimating()
        
        // TODO: Perform search
    }

}

// MARK: - UICollectionViewDataSource
extension ResultsViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let results = results else {
            return .zero
        }
        return results.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResultsCollectionViewCell.reuseIdentifier, for: indexPath) as? ResultsCollectionViewCell else {
            return UICollectionViewCell()
        }

        return cell
        
    }

}

// MARK: - UICollectionViewDelegateFlowLayout
extension ResultsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: AppSettings.collectionInsets.top, left: AppSettings.collectionInsets.left + view.safeAreaInsets.left, bottom: AppSettings.collectionInsets.bottom, right: AppSettings.collectionInsets.right + view.safeAreaInsets.right)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        AppSettings.collectionSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        AppSettings.collectionSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        var width: CGFloat
        var height: CGFloat
        
        let totalWidth = collectionView.bounds.width

        let horizontalInsets = AppSettings.collectionInsets.left + AppSettings.collectionInsets.right + view.safeAreaInsets.right + view.safeAreaInsets.left
        
        height = 200
        
        let numberOfColumns = Int(totalWidth / AppSettings.collectionMinimumColumnWidth)
        guard numberOfColumns > 0 else { return .zero }
        
        width = ( totalWidth - horizontalInsets - CGFloat(numberOfColumns - 1) * AppSettings.collectionSpacing) / CGFloat(numberOfColumns)
        
        return CGSize(width: width, height: height)
        
    }
}
