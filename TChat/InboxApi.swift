//
//  InboxApi.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import Foundation
import Firebase

class InboxApi {
    
    func lastMessages(uid: String) {
        let ref = Ref().databaseInboxForUser(uid: uid)
        ref.observe(DataEventType.childAdded) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any>{
                print(dict)
            }
        }
        
    }
}
