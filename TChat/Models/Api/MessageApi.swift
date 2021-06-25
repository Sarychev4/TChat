//
//  MessageApi.swift
//  TChat
//
//  Created by Артем Сарычев on 30.04.21.
//

import Foundation
import Firebase

class MessageApi {
    func sendMessage(from: String, to: String, value: Dictionary<String, Any>) {
        let chatId = Message.hash(forMembers: [from, to])

        let ref = Database.database().reference().child("feedMessages").child(chatId)
        ref.childByAutoId().updateChildValues(value) { (error, snapshot) in
            if error != nil {
                print(">>>> Ошибка при отправке сообщения: \(error?.localizedDescription ?? "")")
            } else if let messageId = snapshot.key {
                print(">>>> Отправляю сообщение: \(messageId)")
                var dict: [String: Any] = [:]
                dict["id"] = chatId
                dict["participants"] = [from, to]
                dict["lastMessageId"] = messageId
                dict["user1"] = chatId.components(separatedBy:"_").first!
                dict["user2"] = chatId.components(separatedBy:"_").last!
                dict["lastMessageDate"] = value["date"] as? Double ?? Date().timeIntervalSince1970
                dict["isRead"] = false
                dict["inboxSenderId"] = Api.User.currentUserId
                let refFromInbox = Database.database().reference().child(REF_INBOX).child(chatId)
                refFromInbox.updateChildValues(dict)
            }
        }
    }
    
    func getMessage(from chatId: String, with id: String, onComplete: @escaping(Message?) -> Void) {
        let ref = Database.database().reference().child("feedMessages").child(chatId).child(id)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>, let message = Message.transformMessage(dict: dict, keyId: snapshot.key) {
                    onComplete(message)
            } else {
                onComplete(nil)
            }
        }
    }
    
    func receiveMessage(from: String, to: String, onSuccess: @escaping(Message) -> Void) {
        let chatId = Message.hash(forMembers: [from, to])
        let ref = Database.database().reference().child("feedMessages").child(chatId)
        ref.queryOrderedByKey().queryLimited(toLast: 4).observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let message = Message.transformMessage(dict: dict, keyId: snapshot.key) {
                    onSuccess(message)
                }
            }
        }
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
