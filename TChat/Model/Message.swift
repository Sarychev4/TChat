//
//  Message.swift
//  TChat
//
//  Created by Артем Сарычев on 1.05.21.
//

import Foundation

class Message {
    var id: String
    var senderId: String
    var date: Double
    var text: String
    var imageUrl: String
    var height: Double
    var width: Double
    var videoUrl: String
    var audioUrl: String
    var samples: [Float]
    var recordLength: Int
    
    
    init(id: String, senderId: String, date: Double, text: String, imageUrl: String, height: Double, width: Double, videoUrl: String, audioUrl: String, samples: [Float], recordLength: Int) {
        self.id = id
        self.senderId = senderId
        self.date = date
        self.text = text
        self.imageUrl = imageUrl
        self.height = height
        self.width = width
        self.videoUrl = videoUrl
        self.audioUrl = audioUrl
        self.samples = samples
        self.recordLength = recordLength
    }
    
    static func transformMessage(dict: [String: Any], keyId: String) -> Message? {
        
        guard let senderId = dict["sender_id"] as? String,
              let date = dict["date"] as? Double else {
            return nil
        }
        
        let text = (dict["text"] as? String) == nil ? "" : (dict["text"]! as! String)
        
        let imageUrl = (dict["imageUrl"] as? String) == nil ? "" : (dict["imageUrl"]! as! String)
        
        let height = (dict["height"] as? Double) == nil ? 0 : (dict["height"]! as! Double)

        let width = (dict["width"] as? Double) == nil ? 0 : (dict["width"]! as! Double)

        let videoUrl = (dict["videoUrl"] as? String) == nil ? "" : (dict["videoUrl"]! as! String)
        
        let audioUrl = (dict["audioUrl"] as? String) == nil ? "" : (dict["audioUrl"]! as! String)
        
        let samples = (dict["samples"] as? [Float]) == nil ? [0] : (dict["samples"]! as! [Float])
        
        let recordLength = (dict["recordLength"] as? Int) == nil ? 0 : (dict["recordLength"]! as! Int)
        
        let message = Message(id: keyId, senderId: senderId, date: date, text: text, imageUrl: imageUrl, height: height, width: width, videoUrl: videoUrl, audioUrl: audioUrl, samples: samples, recordLength: recordLength)
        return message
    }
    
    static func hash(forMembers members: [String]) -> String {
        let hash = members[0].hashString ^ members[1].hashString
        let memberHash = String(hash)
        return memberHash
    }
    
}