//
//  Inbox.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import Foundation

class Inbox {
    var id: String
    var participantsIDs: [String]
    var lastMessageId: String
    var lastMessageDate: Double

    var lastMessage: Message?
    var participants: [User] = []
    
    //firstUserId: String, secondUserId: String,
    init(id: String, lastMessageId: String, participants: [String], lastMessageDate: Double) {
        self.id = id
        self.lastMessageId = lastMessageId
        self.participantsIDs = participants
        self.lastMessageDate = lastMessageDate
    }
    
    init(withJson dict: [String: Any]) {
        self.id = dict["id"] as? String ?? ""
        self.lastMessageId = dict["lastMessageId"] as? String ?? ""
        self.participantsIDs = dict["participants"] as? [String] ?? []
        self.lastMessageDate = dict["lastMessageDate"] as? Double ?? 0
    }
    
    func update(withJson dict: [String: Any]) {
        self.lastMessageId = dict["lastMessageId"] as? String ?? ""
        self.lastMessageDate = dict["lastMessageDate"] as? Double ?? 0
    }
}
