//
//  InboxTableViewCell.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import UIKit
import Firebase
import SoundWave
import AVFoundation

class InboxTableViewCell: UITableViewCell {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var inboxSoundWaveView: AudioVisualizationView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var messageAvatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var recordLenthLbl: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    @IBOutlet weak var containerForSoundWaveLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerForSoundWave: UIView!
    var user: User!
    
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var controller: InboxListTableViewController!
    
    var inbox: Inbox!
    
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer? 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatar.layer.cornerRadius = 30
        avatar.clipsToBounds = true
        messageAvatar.layer.cornerRadius = 11
        messageAvatar.clipsToBounds = true
        containerForSoundWave.clipsToBounds = true
        
        onlineView.backgroundColor = UIColor.gray
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.layer.cornerRadius = 15/2
        onlineView.clipsToBounds = true
    }
    
    @IBAction func playButtonDidTapped(_ sender: Any) {
        guard let lastMessage = inbox.lastMessage else { return }
        handleAudioPlay()
        if self.player?.rate == 0 {
            self.player!.play()
            let secs = Double(lastMessage.recordLength)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.inboxSoundWaveView.play(for: secs) //MARK:  -TIMEDURATION
               // self.soundWaveViewLeft.play(for: secs)
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + secs) {
                    self.updatedLisenedMessage()
                }
            }
        } else {
            self.player!.pause()
        }
    }
    //MARK: - AUDIO PLAYER
    func handleAudioPlay(){
        
        guard let lastMessage = inbox.lastMessage else { return }
        self.playButton.isHidden = true
        let audioUrl = lastMessage.audioUrl
        if audioUrl.isEmpty{
            return
        }

       // player = AVPlayer(url: audioUrl)
        if let url = URL(string: audioUrl){
            
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
         
        }
        //chatVC.dialogId = cell.
       // chatVC.lastMessageId = cell.
        //Update isRead in inbox
        
            
        
        
    }
    
    func updatedLisenedMessage(){
        let lastMsgId = self.inbox.lastMessageId
        let dialogId = self.inbox.id
//            Database.database().reference().child("feedMessages").child(chatId)
            Ref().databaseInbox.child(dialogId).child("isRead").setValue(true)
            Ref().databaseRoot.child("feedMessages").child(dialogId).child(lastMsgId).child("isRead").setValue(true)
    }
    
    
    func configureCell(uid: String, inbox: Inbox, currentImage: UIImage?){
        guard let lastMessage = inbox.lastMessage, let opponent = inbox.participants.first(where: { $0.uid != Api.User.currentUserId }) else { return }
        self.user = opponent
        self.inbox = inbox
        
        if lastMessage.recordLength < 9 {
            self.recordLenthLbl.text = "00:0\(lastMessage.recordLength)"
        } else if lastMessage.recordLength > 9 && lastMessage.recordLength < 60 {
            self.recordLenthLbl.text = "00:\(lastMessage.recordLength)"
        } else if lastMessage.recordLength > 60 {
            let secs = lastMessage.recordLength - 60
            self.recordLenthLbl.text = "01:\(secs)"
        }
        
        
        
        guard let samples = inbox.lastMessage?.samples else { return }
        self.inboxSoundWaveView.meteringLevelBarWidth = 4.0
        self.inboxSoundWaveView.meteringLevelBarInterItem = 4.0
        self.inboxSoundWaveView.meteringLevelBarCornerRadius = 3.0
        self.inboxSoundWaveView.gradientStartColor = .systemBlue
        self.inboxSoundWaveView.gradientEndColor = .white
        self.inboxSoundWaveView.audioVisualizationMode = .read
        self.inboxSoundWaveView.meteringLevels = samples
        //Не мое - входящее
        //входящее прочитаное
        //входящее непрочитанное
        //мое - отправленное
        //отправленное прочитанное
        //отправленное непрочитанное
        avatar.loadImage(opponent.profileImageUrl)
        self.messageAvatar.isHidden = false
        let isLastMessageMine = lastMessage.senderId == uid
        if isLastMessageMine {
            self.playButton.isHidden = true
            
            if inbox.lastMessage?.isRead == false {
                
                self.inboxSoundWaveView.gradientStartColor = .systemBlue
                self.recordLenthLbl.textColor = .systemBlue
                self.messageAvatar.isHidden = false
                print("1111")
                print("\(lastMessage.isRead)")
            } else {
                self.inboxSoundWaveView.gradientStartColor = .lightGray
                self.recordLenthLbl.textColor = .lightGray
                
                print("2222")
            }
            self.messageAvatar.image = currentImage
            containerForSoundWaveLeftConstraint.constant = 42
            
        } else {
            if inbox.lastMessage?.isRead == false {
                self.playButton.isHidden = false
                self.messageAvatar.image = UIImage(named: "Counter")
                containerForSoundWaveLeftConstraint.constant = 42
                self.recordLenthLbl.textColor = .systemBlue
                print("3333")
            } else {
                self.playButton.isHidden = true
                self.messageAvatar.isHidden = true
                containerForSoundWaveLeftConstraint.constant = 12
                self.inboxSoundWaveView.gradientStartColor = .lightGray
                self.recordLenthLbl.textColor = .lightGray
                print("4444")
               // self.messageAvatar.loadImage(opponent.profileImageUrl)
            }
        }
        
        usernameLbl.text = opponent.username
        let date = Date(timeIntervalSince1970: lastMessage.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLbl.text = dateString
        
        
        
//        if !inbox.text.isEmpty {
//            messageLbl.text = inbox.text
//        } else {
//            messageLbl.text = inbox.audioUrl
//        }
        
        //let refInbox = Ref().databaseInboxInfor(from: Api.User.currentUserId, to: inbox.user.uid)
        
        let refUser = Ref().databaseSpecificUser(uid: opponent.uid)
        if inboxChangedProfileHandle != nil {
            refUser.removeObserver(withHandle: inboxChangedProfileHandle)
        }
        
        inboxChangedProfileHandle = refUser.observe(.childChanged, with: { (snapshot) in
            if let snap = snapshot.value as? String {
                self.user.updateUserData(key: snapshot.key, value: snap)
                self.controller.observeInboxes()
            }
        })
        
        
        let refOnline = Ref().databaseIsOnline(uid: opponent.uid)
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
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse() 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
