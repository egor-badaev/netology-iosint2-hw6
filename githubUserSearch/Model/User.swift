//
//  User.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import Foundation
import SwiftyJSON

enum UserModelError: LocalizedError {
    case invalidModel
    
    var errorDescription: String? {
        return "Отсутствуют обязательные параметры модели"
    }
}

class User {
    var name: String
    var avatarUrl: String
    
    init(fromJson json: JSON) throws {
        guard let login = json["login"].string,
              let avatar_url = json["avatar_url"].string else {
            throw UserModelError.invalidModel
        }
        name = login
        avatarUrl = avatar_url
    }
    
    func printInfo() {
        print("Name: \(name)")
        print("Avatar: \(avatarUrl)")
    }
}
