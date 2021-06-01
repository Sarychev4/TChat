//
//  InboxTableViewCell.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import UIKit
import Firebase
import SoundWave

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var inboxSoundWaveView: AudioVisualizationView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var onlineView: UIView!
    
    var user: User!
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var inboxChangedMessageHandle: DatabaseHandle!
    
    var inbox: Inbox!
    var controller: MessagesTableViewController!
    
    var currentUserImage: UIImage!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        
        onlineView.backgroundColor = UIColor.gray
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.layer.cornerRadius = 15/2
        onlineView.clipsToBounds = true
    }
    
    func configureCell(uid: String, inbox: Inbox, currentImage: UIImage, samples: [Float]){
        self.user = inbox.user
        self.inbox = inbox
        self.currentUserImage = currentImage
        
        self.inboxSoundWaveView.meteringLevelBarWidth = 3.0
        self.inboxSoundWaveView.meteringLevelBarInterItem = 3.0
        self.inboxSoundWaveView.meteringLevelBarCornerRadius = 0.0
        self.inboxSoundWaveView.gradientStartColor = .blue
        self.inboxSoundWaveView.gradientEndColor = .black
        self.inboxSoundWaveView.audioVisualizationMode = .read
        self.inboxSoundWaveView.meteringLevels = samples
        
        
        avatar.loadImage(inbox.user.profileImageUrl)
        usernameLbl.text = inbox.user.username
        let date = Date(timeIntervalSince1970: inbox.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLbl.text = dateString
        
        if !inbox.text.isEmpty {
            messageLbl.text = inbox.text
        } else {
            messageLbl.text = inbox.audioUrl
        }
        
        //let refInbox = Ref().databaseInboxInfor(from: Api.User.currentUserId, to: inbox.user.uid)
        let channelId = Message.hash(forMembers: [Api.User.currentUserId, inbox.user.uid])
        let refInbox = Database.database().reference().child(REF_INBOX).child(Api.User.currentUserId).child(channelId)
        if inboxChangedMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangedMessageHandle)
        }
        
        inboxChangedMessageHandle = refInbox.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value {
                self.inbox.updateInboxData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
        
        
        let refOnline = Ref().databaseIsOnline(uid: inbox.user.uid)
        refOnline.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any> {
                if let active = snap["online"] as? Bool {
                    self.onlineView.backgroundColor = active == true ? .cyan : .gray
                }
            }
        }
        
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        inboxChangedOnlineHandle = refOnline.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.onlineView.backgroundColor = (snap as! Bool) == true ? .cyan : .gray
                }
            }
        }
        
        let refUser = Ref().databaseSpecificUser(uid: inbox.user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateUserData(key: snapshot.key, value: snap)
                self.controller.sortedInbox()
            }
        })
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let refOnline = Ref().databaseIsOnline(uid: self.inbox.user.uid)
        if inboxChangedOnlineHandle != nil {
            refOnline.removeObserver(withHandle: inboxChangedOnlineHandle)
        }
        
        let refUser = Ref().databaseSpecificUser(uid: inbox.user.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        let channelId = Message.hash(forMembers: [Api.User.currentUserId, inbox.user.uid])
        let refInbox = Database.database().reference().child(REF_INBOX).child(Api.User.currentUserId).child(channelId)
        if inboxChangedMessageHandle != nil {
            refInbox.removeObserver(withHandle: inboxChangedMessageHandle)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
