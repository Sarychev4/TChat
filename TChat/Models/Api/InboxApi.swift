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
    
    var inboxes: [Inbox] {
        get {
            return LocalCacheService.shared.inboxes
        }
        set {
            LocalCacheService.shared.inboxes = newValue
        }
    }
    
    func loadMore(start timestamp: Double?, controller: InboxListTableViewController, from: String, onSuccess: @escaping(InboxCompletion)) {
    }
    
    func observeInboxes(onUpdate: @escaping(() -> Void)) {
        let ref = Database.database().reference().child(REF_INBOX)
        
        let userId = Api.User.currentUserId
        ref.queryOrdered(byChild: "user1").queryEqual(toValue: userId).observe(.value) { snapshot in
            self.processInboxSnapshot(snapshot, onUpdate: onUpdate)
        }
        
        ref.queryOrdered(byChild: "user2").queryEqual(toValue: userId).observe(.value) { snapshot in
            self.processInboxSnapshot(snapshot, onUpdate: onUpdate)
        }

    }
    
    func processInboxSnapshot(_ snapshot: DataSnapshot, onUpdate: @escaping(() -> Void)) {
        if let response = snapshot.value as? [String: Any], let inboxesJsons = Array(response.values) as? [[String: Any]] {
          for inboxJson in inboxesJsons {
            let inboxId = inboxJson["id"] as! String
            
            print(">>> Загружаю inbox, id: \(inboxId)")
            var inbox:Inbox! = self.inboxes.first(where: { $0.id == inboxId })
            if inbox == nil {
                print(">>> Не нашел в кэше, создаю новый inbox, id: \(inboxId)")
                inbox = Inbox(withJson: inboxJson)
                self.inboxes.append(inbox)
            } else {
                print(">>> Нашел чат в кэше, обновляю последнее сообщение")
                inbox.update(withJson:inboxJson)
            }
            
            let dispatchGroup = DispatchGroup()
            inbox.participantsIDs.forEach { (participantId) in
                // Если не скачивал данные о себе и опоненте, скачиваю и добавляю в модельку
                if inbox.participants.contains(where: { $0.uid == participantId }) == false {
                    print(">>> Загружаю данные об участнике чата id: \(participantId)")
                    dispatchGroup.enter()
                    Api.User.getUserInfor(uid: participantId, onSuccess: { (user) in
                        print(">>> Загрузил данные об участнике чата id: \(participantId)")
                        inbox.participants.append(user)
                        dispatchGroup.leave()
                    })
                }
            }
             
            print(">>> Загружаю данные о последнем сообщении в чате id: \(inbox.lastMessageId)")
            dispatchGroup.enter()
            Api.Message.getMessage(from: inboxId, with: inbox.lastMessageId) { (message) in
                print(">>> Загрузил данные о последнем сообщении")
                if let message = message {
                    inbox.lastMessage = message
                    print(">>> В последнем сообщении read: \(message.isRead)")
                }
                dispatchGroup.leave()
            }
            
            self.inboxes = self.inboxes.sorted(by: { $0.lastMessageDate > $1.lastMessageDate })
            dispatchGroup.notify(queue: .main) {
                print(">>> Данные о чате полностью загружены. paticipants: \(inbox.participants.count), lastM: \(inbox.lastMessage?.id)")
                onUpdate()
            }
          }

            
        }
    }
    
}
