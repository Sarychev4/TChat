//
//  InboxApi.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import Foundation
import Firebase

typealias InboxCompletion = (Inbox) -> Void

class InboxApi {
    
    func lastMessages(uid: String, onSuccess: @escaping(InboxCompletion)) {
//        let ref = Ref().databaseInboxForUser(uid: uid)
//        ref.observe(DataEventType.childAdded) { (snapshot) in
//            if let dict = snapshot.value as? Dictionary<String, Any>{
//                //print(dict)
//                Api.User.getUserInfor(uid: snapshot.key, onSuccess: {(user) in
//                    if let inbox = Inbox.transformInbox(dict: dict, user: user){
//                        onSuccess(inbox)
//                    }
//                })
//            }
//        }
        
        let ref = Database.database().reference().child(REF_INBOX).child(uid)
        ref.observe(DataEventType.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {

                guard let partnerId = dict["to"] as? String else {
                    return
                }
        let uid = (partnerId == Api.User.currentUserId) ? (dict["from"] as! String) : partnerId
                //let channelId = Message.hash(forMembers: [uid, partnerId])

                Api.User.getUserInfor(uid: uid, onSuccess: { (user) in
                    if let inbox = Inbox.transformInbox(dict: dict, user: user) {
                        onSuccess(inbox)
                    }
                })
            }
        }
        
    }

}
