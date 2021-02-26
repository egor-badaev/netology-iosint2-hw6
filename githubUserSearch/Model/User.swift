//
//  User.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import Foundation
import SwiftyJSON

class User {
    var name: String
    var avatarUrl: String
    
    init(fromJson json: JSON) {
        guard let login = json["login"].string,
              let avatar_url = json["avatar_url"].string else {
            name = "ERROR"
            avatarUrl = ""
            return
        }
        name = login
        avatarUrl = avatar_url
    }
    
    func printInfo() {
        print("Name: \(name)")
        print("Avatar: \(avatarUrl)")
    }
}
