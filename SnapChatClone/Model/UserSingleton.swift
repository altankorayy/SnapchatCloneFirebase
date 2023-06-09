//
//  UserSingleton.swift
//  SnapChatClone
//
//  Created by Altan on 26.05.2023.
//

import Foundation

class UserSingleton {
    
    static let sharedUserInfo = UserSingleton()
    
    var email = ""
    var username = ""
    
    private init() {
        
    }
}
