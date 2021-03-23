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
    var networkManager: NetworkService
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
        collectionView.prefetchDataSource = self
        
        // Hide view while loading data
        collectionView.isHidden = true
        
        return collectionView
    }()
    
    private let imageFetcher = ResultsImageFetcher.shared

    
    // MARK: - Life cycle
    
    init(_ term: String) {
        self.term = term
        self.networkManager = NetworkService.sharedManager
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
        
        networkManager.search(user: term) { data in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
            }
            guard let json = try? JSON(data: data) else {
                return
            }
            self.results = Results(fromJson: json)
            guard let results = self.results else { return }

            print("Found \(results.count) results")

            DispatchQueue.main.async { [weak self] in
                self?.collectionView.isHidden = false
                self?.collectionView.reloadData()
            }

        } onFailure: { errorMessage in
            DispatchQueue.main.async { [weak self] in
                self?.activityIndicator.stopAnimating()
                self?.present(AlertFactory.makeErrorAlert(message: errorMessage), animated: true, completion: nil)
            }
        }
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
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ResultsCollectionViewCell.reuseIdentifier, for: indexPath) as? ResultsCollectionViewCell,
              let user = results?.users[indexPath.item] else {
            return UICollectionViewCell()
        }
        
        let identifier = user.identifier
        
        cell.representedIdentifier = identifier
        
        if let fetchedImage = imageFetcher.fetchedImage(for: identifier) {
            cell.configure(withName: user.name, avatar: fetchedImage, identifier: identifier)
        } else {
            cell.resetData()
            
            imageFetcher.fetchAsync(from: user.avatarUrl, for: identifier) { result in
                
                guard cell.representedIdentifier == identifier else { return }
                
                switch result {
                case .failure(let error):
                    print(error.localizedDescription)
                    return
                case .success(let image):
                    DispatchQueue.main.async {
                        cell.configure(withName: user.name, avatar: image, identifier: identifier)
                    }
                    
                }
            }
        }
        
        return cell
        
    }

}

// MARK: - UICollectionViewDataSourcePrefetching
extension ResultsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let results = results else { return }
        for indexPath in indexPaths {
            let user = results.users[indexPath.item]
            imageFetcher.fetchAsync(from: user.avatarUrl, for: user.identifier)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let results = results else { return }
        for indexPath in indexPaths {
            let user = results.users[indexPath.item]
            imageFetcher.calcelFetch(for: user.identifier)
        }
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
