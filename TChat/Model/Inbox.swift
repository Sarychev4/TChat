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
    
    static func transformInbox(dict: [String: Any], channel: String,  user: User) -> Inbox? {
        
        guard let id = dict["id"] as? String,
              let participants = dict["participants"] as? [String],
              let lastMessageId = dict["lastMessageId"] as? String,
              let lastMessageDate = dict["lastMessageDate"] as? Double
        else { return nil }
        
        let inbox = Inbox(id: id, lastMessageId: lastMessageId, participants: participants, lastMessageDate: lastMessageDate)
        return inbox
    }
}
