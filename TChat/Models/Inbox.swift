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
    var inboxSenderId: String

    var lastMessage: Message?
    var participants: [User] = []
    
    //firstUserId: String, secondUserId: String,
    init(id: String, lastMessageId: String, participants: [String], lastMessageDate: Double, inboxSenderId: String) {
        self.id = id
        self.lastMessageId = lastMessageId
        self.participantsIDs = participants
        self.lastMessageDate = lastMessageDate
        self.inboxSenderId = inboxSenderId
    }
    
    init(withJson dict: [String: Any]) {
        self.id = dict["id"] as? String ?? ""
        self.lastMessageId = dict["lastMessageId"] as? String ?? ""
        self.participantsIDs = dict["participants"] as? [String] ?? []
        self.lastMessageDate = dict["lastMessageDate"] as? Double ?? 0
        self.inboxSenderId = dict["inboxSenderId"] as? String ?? ""
    }
    
    func update(withJson dict: [String: Any]) {
        self.lastMessageId = dict["lastMessageId"] as? String ?? ""
        self.lastMessageDate = dict["lastMessageDate"] as? Double ?? 0
        self.inboxSenderId = dict["inboxSenderId"] as? String ?? ""
    }
}
