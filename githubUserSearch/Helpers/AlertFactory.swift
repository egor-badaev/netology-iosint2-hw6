//
//  AlertFactory.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import UIKit

struct AlertFactory {
    
    static func makeInfoAlert(title: String?, messsage: String?) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: messsage, preferredStyle: .alert)
        let alertOkAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertOkAction)
        return alertController
    }
    
    static func makeErrorAlert(message: String?) -> UIAlertController {
        return AlertFactory.makeInfoAlert(title: "Ошибка!", messsage: message)
    }
}
