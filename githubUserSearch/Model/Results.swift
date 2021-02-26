//
//  Results.swift
//  githubUserSearch
//
//  Created by Egor Badaev on 26.02.2021.
//

import Foundation
import SwiftyJSON

class Results {
    var users: [User]
    
    var count: Int {
        return users.count
    }
    
    init(fromJson json: JSON) {
        users = []
        
        let items = json["items"].arrayValue
        
        items.forEach { itemJson in
            let user = User(fromJson: itemJson)
            users.append(user)
        }
    }
}
