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
    private var networkManager: NetworkService
    private var timerProvider: TimerProvider
    private var results: Results?
    private var headerView: ResultsCollectionViewHeader?
    
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
        collectionView.register(ResultsCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ResultsCollectionViewHeader.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Hide view while loading data
        collectionView.isHidden = true
        
        return collectionView
    }()

    
    // MARK: - Life cycle
    
    init(_ term: String) {
        self.term = term
        self.networkManager = NetworkService.sharedManager
        timerProvider = TimerProvider(timeInterval: 0.1, reloadInterval: AppSettings.reloadInterval)
        super.init(nibName: nil, bundle: nil)
        timerProvider.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timerProvider.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timerProvider.stopTimer()
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
                guard let self = self else { return }
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
            }

        } onFailure: { errorMessage in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.activityIndicator.stopAnimating()
                self.present(AlertFactory.makeErrorAlert(message: errorMessage), animated: true, completion: nil)
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
        
        cell.configure(withName: user.name, avatarUrl: user.avatarUrl)
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print(type(of: self), #function)
        headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ResultsCollectionViewHeader.reuseIdentifier, for: indexPath) as? ResultsCollectionViewHeader
        guard let headerView = headerView else {
            print("Unexpected")
            return UICollectionReusableView()
        }
        headerView.updateTimer(with: timerProvider.countdown)
        return headerView
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let headerView = headerView else {
            return CGSize(width: collectionView.frame.width, height: 90)
        }
        
        /// From [stack overflow](https://stackoverflow.com/questions/39825290/uicollectionview-header-dynamic-height-using-auto-layout)
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width, height: UIView.layoutFittingExpandedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)

    }
}

extension ResultsViewController: TimerProviderDelegate {
    func reloadData() {
        // reset data
        results?.users = []
        collectionView.reloadData()
        collectionView.isHidden = true
        activityIndicator.isHidden = false
        
        // load data again
        fetchData()
    }
    
    func updateTimer(countdown: Int) {
        headerView?.updateTimer(with: countdown)
    }
}
