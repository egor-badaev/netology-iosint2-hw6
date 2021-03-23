//
//  User.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import Foundation
import SwiftyJSON

class User {
    var identifier: Int
    var name: String
    var avatarUrl: String
    
    init(fromJson json: JSON) {
        guard let id = json["id"].int,
              let login = json["login"].string,
              let avatar = json["avatar_url"].string else {
            identifier = 0
            name = "ERROR"
            avatarUrl = ""
            return
        }
        identifier = id
        name = login
        avatarUrl = avatar
    }
    
    func printInfo() {
        print("Name: \(name)")
        print("Avatar: \(avatarUrl)")
    }
}
