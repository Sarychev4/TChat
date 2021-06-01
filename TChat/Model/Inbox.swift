//
//  Inbox.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import Foundation

class Inbox {
    var date: Double
    var text: String
    var user: User
    var read = false
    var channel: String
    var audioUrl: String
    var samples: [Float]
    
    init(date: Double, text: String, user: User, read: Bool, channel: String, audioUrl: String, samples: [Float]) {
        self.date = date
        self.text = text
        self.user = user
        self.read = read
        self.channel = channel
        self.audioUrl = audioUrl
        self.samples = samples
    }
    
    static func transformInbox(dict: [String: Any], channel: String,  user: User) -> Inbox? {
        
        guard let date = dict["date"] as? Double,
              let text = dict["text"] as? String,
              let read = dict["read"] as? Bool,
              let audioUrl = dict["audioUrl"] as? String,
              let samples = dict["samples"] as? [Float] else {
            return nil
        }
        
        let inbox = Inbox(date: date, text: text, user: user, read: read, channel: channel, audioUrl: audioUrl, samples: samples)
        
        return inbox
    }
    
    func updateInboxData(key: String, value: Any) {
        switch key {
        case "text": self.text = value as! String
        case "date": self.date = value as! Double
        case "samples": self.samples = value as! [Float]
        default:
            break
        }
    }
}
