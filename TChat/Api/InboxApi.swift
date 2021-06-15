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
    
    func observeInboxes(uid: String, onSuccess: @escaping(InboxCompletion)) {
        
        let ref = Database.database().reference().child(REF_INBOX)
        ref.queryOrdered(byChild: "date").observe(.value) { (snapshot) in
            if let response = snapshot.value as? [String: Any], let dict = response.values.first as? [String: Any] {

                let channelId = response.keys.first ?? ""
                let uid = dict["sender_id"] as? String ?? ""
                
                Api.User.getUserInfor(uid: uid, onSuccess: { (user) in
                    if let inbox = Inbox.transformInbox(dict: dict, channel: channelId, user: user) {
                        onSuccess(inbox)
                    }
                })
            }
        }
        
    }
    
    func loadMore(start timestamp: Double?, controller: InboxListTableViewController, from: String, onSuccess: @escaping(InboxCompletion)) {
        guard let timestamp = timestamp else {
            return
        }
        let ref = Database.database().reference().child(REF_INBOX).queryOrdered(byChild: "date").queryEnding(atValue: timestamp - 1).queryLimited(toLast: 30)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            if allObjects.isEmpty {
                controller.tableView.tableFooterView = UIView()
            }
            
            allObjects.forEach({ (object) in
                if let dict = object.value as? Dictionary<String, Any> {
                    guard let partnerId = dict["to"] as? String else {
                        return
                    }
                    let channelId = Message.hash(forMembers: [from, partnerId])
                    Api.User.getUserInfor(uid: partnerId, onSuccess: { (user) in
                        if let inbox = Inbox.transformInbox(dict: dict, channel: channelId, user: user) {
                            onSuccess(inbox)
                        }
                    })
                }
            })
        }
    }
    
}
