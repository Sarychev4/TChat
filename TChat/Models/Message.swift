//
//  Message.swift
//  TChat
//
//  Created by Артем Сарычев on 1.05.21.
//

import Foundation
import CoreGraphics

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
    //var samples: [Float]
    var cuttedInboxSamples: [Float]
    var cuttedMessageSamples: [Float]
    
    var recordLength: Double
    var isRead: Bool
    
    
    
    init(id: String, senderId: String, date: Double, text: String, imageUrl: String, height: Double, width: Double, videoUrl: String, audioUrl: String, cuttedInboxSamples: [Float], cuttedMessageSamples: [Float], recordLength: Double, isRead: Bool) { //samples: [Float]
        self.id = id
        self.senderId = senderId
        self.date = date
        self.text = text
        self.imageUrl = imageUrl
        self.height = height
        self.width = width
        self.videoUrl = videoUrl
        self.audioUrl = audioUrl
        //self.samples = samples
        self.cuttedInboxSamples = cuttedInboxSamples
        self.cuttedMessageSamples = cuttedMessageSamples
        
        self.recordLength = recordLength
        self.isRead = isRead
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
        
       // let samples = (dict["samples"] as? [CGFloat]) == nil ? [0] : (dict["samples"]! as! [CGFloat])
        let cuttedInboxSamples = (dict["cuttedInboxSamples"] as? [CGFloat]) == nil ? [0] : (dict["cuttedInboxSamples"]! as! [CGFloat])
        
        let cuttedMessageSamples = (dict["cuttedMessageSamples"] as? [CGFloat]) == nil ? [0] : (dict["cuttedMessageSamples"]! as! [CGFloat])
        
        let recordLength = (dict["recordLength"] as? Double) == nil ? 0 : (dict["recordLength"]! as! Double)
        
        let isRead = (dict["isRead"] as? Bool) ?? true
        
        let message = Message(id: keyId, senderId: senderId, date: date, text: text, imageUrl: imageUrl, height: height, width: width, videoUrl: videoUrl, audioUrl: audioUrl, cuttedInboxSamples: cuttedInboxSamples.map({ Float($0) }), cuttedMessageSamples: cuttedMessageSamples.map({ Float($0) }), recordLength: recordLength, isRead: isRead) //samples: samples.map({ Float($0) })
        return message
    }
    
    static func hash(forMembers members: [String]) -> String { 
        return members.sorted().joined(separator: "_")
    }
    
}
