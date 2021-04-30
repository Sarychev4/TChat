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
        let ref = Ref().databaseMessageSendTo(from: from, to: to)
        ref.childByAutoId().updateChildValues(value)
    }
    
    func receiveMessage(from: String, to: String, onSucces: @escaping(Message) -> Void){
        let ref = Ref().databaseMessageSendTo(from: from, to: to)
        ref.observe(.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                if let message = Message.transformMessage(dict: dict, keyId: snapshot.key){
                    onSucces(message)
                }
            }
        }
    }
}
