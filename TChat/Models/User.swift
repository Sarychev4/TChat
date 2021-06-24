//
//  User.swift
//  TChat
//
//  Created by Артем Сарычев on 29.04.21.
//

import Foundation

class User: Hashable, Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    var hashValue: Int {
        return uid.hashValue
    }
    
    var uid: String
    var username: String
    var email: String
    var profileImageUrl: String
    var status: String
    var inboxes: [String] = []
    
    init(uid: String, username: String, email: String, profileImageUrl: String, status: String, inboxes: [String]) {
        self.uid = uid
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
        self.status = status
        self.inboxes = inboxes
    }
    
    static func transformUser(dict: [String: Any]) -> User? {
        
        guard let uid = dict["uid"] as? String,
              let username = dict["username"] as? String,
              let email = dict["email"] as? String,
              let profileImageUrl = dict["profileImageUrl"] as? String,
              let status = dict["status"] as? String
        else {
            return nil
        }
        let inboxes = dict["inboxes"] as? [String] ?? []
        let user = User(uid: uid, username: username, email: email, profileImageUrl: profileImageUrl, status: status, inboxes: inboxes)
        return user
    }
    
    func updateUserData(key: String, value: Any) {
        switch key {
        case "username": self.username = value as? String ?? ""
        case "email": self.email = value as? String ?? ""
        case "profileImageUrl": self.profileImageUrl = value as? String ?? ""
        case "status": self.status = value as? String ?? ""
        case "inboxes": self.inboxes = value as? [String] ?? []
        default:
            break
        }
    }
}
