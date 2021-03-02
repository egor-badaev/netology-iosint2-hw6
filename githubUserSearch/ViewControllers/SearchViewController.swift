//
//  ViewController.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 25.02.2021.
//

import UIKit

class SearchViewController: UIViewController {
    
    //MARK: - Properties
    
    private let titleLabel: UILabel = {
        $0.toAutoLayout()
        $0.text = "Github User Search"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        $0.textAlignment = .center
        return $0
    }(UILabel())
    
    private let searchField: UITextField = {
        $0.toAutoLayout()
        $0.backgroundColor = .white
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.placeholder = "Who are you looking for?"
        $0.textAlignment = .center
        return $0
    }(UITextField())
    
    private lazy var searchButton: UIButton = {
        $0.toAutoLayout()
        
        $0.setTitle("Search", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        $0.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        $0.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        
        $0.addTarget(self, action: #selector(searchButtonTapped(_:)), for: .touchUpInside)
        
        return $0
    }(UIButton(type: .system))
    
    private lazy var stackView: UIStackView = {
        
        $0.toAutoLayout()
        
        $0.spacing = AppSettings.spacing
        $0.axis = .vertical
        
        return $0
    }(UIStackView())
    
    private let validator = UserInputValidator(allowingLengthsFrom: 1,
                                               to: 39,
                                               matching: "^[a-z0-9](?:[a-z0-9]|-(?=[a-z0-9])){0,38}$",
                                               negating: "[^a-z0-9-]")

    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Github user search"
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(searchField)
        stackView.addArrangedSubview(searchButton)
        
        let constraints = [
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppSettings.margin),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppSettings.margin),
            searchField.heightAnchor.constraint(equalToConstant: AppSettings.controlSize),
            searchButton.heightAnchor.constraint(equalToConstant: AppSettings.controlSize)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }

    //MARK: - Actions
    
    @objc private func searchButtonTapped(_ sender: UIButton) {
        validator.validateInput(fromTextField: searchField) { result in
            switch result {
            case .failure(let error):
                self.present(AlertFactory.makeErrorAlert(message: error.localizedDescription), animated: true, completion: nil)
            case .success(let term):
                print("Searching for user \(term)...")
                let resultsVC = ResultsViewController(term)
                navigationController?.pushViewController(resultsVC, animated: true)
            }
        }
    }
}

