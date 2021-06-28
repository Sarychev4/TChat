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
    private struct KeyPath {
        
        struct PlayerItem {
            static let Status = "status"
        }
    }
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var messageAvatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var recordLenthLbl: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    @IBOutlet weak var containerForSoundWaveLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerForSoundWave: UIView!
    
    @IBOutlet weak var soundLinesView: InboxCurves!
    @IBOutlet weak var soundLinesViewReaded: InboxCurves!
    
    @IBOutlet weak var containerForSoundLinesViewReaded: UIView!
    @IBOutlet weak var containerForSoundLinesViewReadedRightConstraint: NSLayoutConstraint!
    
    var user: User!
    var inbox: Inbox!
    
    var inboxChangedOnlineHandle: DatabaseHandle!
    var inboxChangedProfileHandle: DatabaseHandle!
    var controller: InboxListTableViewController!
    
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
        containerForSoundLinesViewReaded.clipsToBounds = true
        onlineView.backgroundColor = UIColor.gray
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor.white.cgColor
        onlineView.layer.cornerRadius = 15/2
        onlineView.clipsToBounds = true
    }
    
    @IBAction func playButtonDidTapped(_ sender: Any) {
        handleAudioPlay()
    }
    
    //MARK: - AUDIO PLAYER
    func handleAudioPlay(){
        
        guard let lastMessage = inbox.lastMessage else { return }
        self.playButton.isHidden = true
        
        let audioUrl = lastMessage.audioUrl
        if audioUrl.isEmpty{
            return
        }

        if let url = URL(string: audioUrl) {
            player?.currentItem?.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status)
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.Status, options: [.initial, .new], context: nil)
            
            playerLayer = AVPlayerLayer(player: player)
        }
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == KeyPath.PlayerItem.Status {
            if let statusInt = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: statusInt) {
                switch status {
                case .unknown:
                    break
                case .readyToPlay:
                    guard let lastMessage = inbox.lastMessage else { return }
                    if self.player?.rate == 0 {
                    
                        UIView.animate(withDuration: lastMessage.recordLength + 0.5, animations: {
                            self.containerForSoundLinesViewReadedRightConstraint.constant = 0
                            self.containerForSoundWave.layoutIfNeeded()
                        }, completion: { (finished: Bool) in
                            self.updatedLisenedMessage()
                        })
                        self.player!.play()
                      
                    } else {
                        self.player!.pause()
                    }
                case .failed:
                    break
                @unknown default:
                    break
                }
            }
        }
    }
    
    func updatedLisenedMessage(){
        let lastMsgId = self.inbox.lastMessageId
        let dialogId = self.inbox.id
        Ref().databaseRoot.child("feedMessages").child(dialogId).child(lastMsgId).child("isRead").setValue(true)
        Ref().databaseInbox.child(dialogId).child("isRead").setValue(true)
    }
    
    
    func configureCell(uid: String, inbox: Inbox, currentImage: UIImage?){
        guard let lastMessage = inbox.lastMessage, let opponent = inbox.participants.first(where: { $0.uid != Api.User.currentUserId }) else { return }
        self.user = opponent
        self.inbox = inbox
        
        guard let samples = inbox.lastMessage?.cuttedInboxSamples else { return }
        
        self.soundLinesView.samples = samples
        self.soundLinesViewReaded.samples = samples
        self.containerForSoundLinesViewReaded.clipsToBounds = true
        
        self.avatar.kf.setImage(with: URL(string: opponent.profileImageUrl)!)
        self.messageAvatar.isHidden = false
        let isLastMessageMine = lastMessage.senderId == uid
        
        if isLastMessageMine { //My message

            self.playButton.isHidden = true
            containerForSoundWaveLeftConstraint.constant = 42
            
            if inbox.lastMessage?.isRead == false {
                self.messageAvatar.isHidden = false
                self.messageAvatar.image = currentImage
                self.recordLenthLbl.textColor = UIColor(hexString: "BFBFBF")
                self.soundLinesView.tintColor = UIColor(hexString: "AA75EE")
                self.containerForSoundLinesViewReadedRightConstraint.constant = containerForSoundWave.bounds.width
            } else {
                self.messageAvatar.isHidden = false
                self.messageAvatar.image = currentImage
                self.recordLenthLbl.textColor = UIColor(hexString: "BFBFBF")
                self.soundLinesView.tintColor = UIColor(hexString: "BFBFBF")
                self.containerForSoundLinesViewReadedRightConstraint.constant = 0
            }
        } else {
            if inbox.lastMessage?.isRead == false { //unreaded
                self.playButton.isHidden = false
                self.messageAvatar.image = UIImage(named: "Counter")
                containerForSoundWaveLeftConstraint.constant = 42
                self.containerForSoundLinesViewReadedRightConstraint.constant = containerForSoundWave.bounds.width
                self.recordLenthLbl.textColor = UIColor(hexString: "0584FE")
            } else {
                self.playButton.isHidden = true
                self.messageAvatar.isHidden = true
                containerForSoundWaveLeftConstraint.constant = 12
                self.containerForSoundLinesViewReadedRightConstraint.constant = 0
                self.recordLenthLbl.textColor = UIColor(hexString: "BFBFBF")
            }
        }
        
        usernameLbl.text = opponent.username
        let date = Date(timeIntervalSince1970: lastMessage.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLbl.text = dateString
        
        if lastMessage.recordLength < 9 {
            self.recordLenthLbl.text = "00:0\(String(format: "%.0f", lastMessage.recordLength))"
        } else if lastMessage.recordLength > 9 && lastMessage.recordLength < 60 {
            self.recordLenthLbl.text = "00:\(String(format: "%.0f", lastMessage.recordLength))"
        } else if lastMessage.recordLength > 60 {
            let secs = lastMessage.recordLength - 60
            self.recordLenthLbl.text = "01:\(String(format: "%.0f", secs))"//"01:\(secs)"
            //String(format: "%.1f", counter)
        }
         
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

    }

}
