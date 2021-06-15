//
//  MessageApi.swift
//  TChat
//
//  Created by Артем Сарычев on 30.04.21.
//

import Foundation
import Firebase

class MessageApi {
    func sendMessage(from: String, to: String, value: Dictionary<String, Any>){

//        let ref = Ref().databaseMessageSendTo(from: from, to: to)
//        ref.childByAutoId().updateChildValues(value)
//
//        var dict = value
//        if let text = dict["text"] as? String, text.isEmpty {
//            dict["imageUrl"] = nil
//            dict["height"] = nil
//            dict["width"] = nil
//        }
//
//
//        let refFrom = Ref().databaseInboxInfor(from: from, to: to)
//        refFrom.updateChildValues(dict)
//
//        let refTo = Ref().databaseInboxInfor(from: to, to: from)
//        refTo.updateChildValues(dict)
        
        let channelId = Message.hash(forMembers: [from, to])
        var lastMessageID = ""
        let ref = Database.database().reference().child("feedMessages")
        ref.childByAutoId().updateChildValues(value) { (error, snapshot) in
            if error != nil{
                print(error?.localizedDescription)
                
            } else {
                lastMessageID = snapshot.key ?? "gg"
                
                var dict = value
                if let text = dict["text"] as? String, text.isEmpty {
                    dict["imageUrl"] = nil
                    dict["height"] = nil
                    dict["width"] = nil
                }
                dict["id"] = channelId
                dict["lastMessageId"] = lastMessageID
                let refFromInbox = Database.database().reference().child(REF_INBOX).child(channelId)
                refFromInbox.updateChildValues(dict)
            }
            
        }
    }
    
    func getMessage(with id: String, onComplete: @escaping(Message) -> Void) {
        let ref = Database.database().reference().child("feedMessages").child(id)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let message = Message.transformMessage(dict: dict, keyId: snapshot.key) {
                    onComplete(message)
                }
            }
        }
    }
    
    func receiveMessage(from: String, to: String, onSucces: @escaping(Message) -> Void){
        let channelId = Message.hash(forMembers: [from, to])
        let ref = Database.database().reference().child("feedMessages").child(channelId)
        ref.queryOrderedByKey().queryLimited(toLast: 4).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let message = Message.transformMessage(dict: dict, keyId: snapshot.key) {
                    onSucces(message)
                }
            }
        }
//        let ref = Ref().databaseMessageSendTo(from: from, to: to)
//        ref.observe(.childAdded) { (snapshot) in
//            if let dict = snapshot.value as? Dictionary<String, Any>{
//                if let message = Message.transformMessage(dict: dict, keyId: snapshot.key){
//
//                    onSucces(message)
//                }
//            }
//        }
    }
    
    func loadMore(lastMessageKey: String?, from: String, to: String, onSuccess: @escaping([Message], String) -> Void){
        if lastMessageKey != nil {
            let channelId = Message.hash(forMembers: [from, to])
            let ref = Database.database().reference().child("feedMessages").child(channelId)
            ref.queryOrderedByKey().queryEnding(atValue: lastMessageKey).queryLimited(toLast: 5).observeSingleEvent(of: .value) { (snapshot) in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else {
                    return
                }
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                    return
                }
                var messages = [Message]()
                allObjects.forEach({ (object) in
                    if let dict = object.value as? Dictionary<String, Any> {
                        if let message = Message.transformMessage(dict: dict, keyId: snapshot.key){
                            if object.key != lastMessageKey {
                                messages.append(message)
                            }
                            
                        }
                    }
                })
                onSuccess(messages, first.key)
            }
        }
    }
}
