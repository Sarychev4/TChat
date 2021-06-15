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

    @IBOutlet weak var inboxSoundWaveView: AudioVisualizationView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var messageAvatar: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    
    @IBOutlet weak var recordLenthLbl: UILabel!
    @IBOutlet weak var onlineView: UIView!
    
    @IBOutlet weak var containerForSoundWave: UIView!
    var user: User! 
    
    var inbox: Inbox!
    var controller: InboxListTableViewController!
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    var currentUserImage: UIImage!
    
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
        handleAudioPlay()
        if self.player?.rate == 0 {
            self.player!.play()
            let secs = Double(self.inbox.recordLength)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.inboxSoundWaveView.play(for: secs) //MARK:  -TIMEDURATION
               // self.soundWaveViewLeft.play(for: secs)
            }
        } else {
            self.player!.pause()
        }
    }
    //MARK: - AUDIO PLAYER
    func handleAudioPlay(){
        let audioUrl = inbox.audioUrl
        if audioUrl.isEmpty{
            return
        }

       // player = AVPlayer(url: audioUrl)
        if let url = URL(string: audioUrl){
            
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
         
        }
        
    }
    
    
    func configureCell(uid: String, inbox: Inbox, currentImage: UIImage, samples: [Float]){
        self.user = inbox.user
        self.inbox = inbox
        self.currentUserImage = currentImage
        
        if inbox.recordLength < 9 {
            self.recordLenthLbl.text = "00:0\(inbox.recordLength)"
        }else if inbox.recordLength > 9 && inbox.recordLength < 60{
            self.recordLenthLbl.text = "00:\(inbox.recordLength)"
        }else if inbox.recordLength > 60{
            let secs = inbox.recordLength - 60
            self.recordLenthLbl.text = "01:\(secs)"
        }
       
        avatar.loadImage(inbox.user.profileImageUrl)
        
        if uid == inbox.senderId {
            self.messageAvatar.image = currentImage
        } else {
            
            self.messageAvatar.loadImage(inbox.user.profileImageUrl)
        }
        
        
        self.inboxSoundWaveView.meteringLevelBarWidth = 3.0
        self.inboxSoundWaveView.meteringLevelBarInterItem = 3.0
        self.inboxSoundWaveView.meteringLevelBarCornerRadius = 0.0
        self.inboxSoundWaveView.gradientStartColor = .blue
        self.inboxSoundWaveView.gradientEndColor = .white
        self.inboxSoundWaveView.audioVisualizationMode = .read
        self.inboxSoundWaveView.meteringLevels = samples
        
        
        
        
        usernameLbl.text = inbox.user.username
        let date = Date(timeIntervalSince1970: inbox.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLbl.text = dateString
        
//        if !inbox.text.isEmpty {
//            messageLbl.text = inbox.text
//        } else {
//            messageLbl.text = inbox.audioUrl
//        }
        
        //let refInbox = Ref().databaseInboxInfor(from: Api.User.currentUserId, to: inbox.user.uid)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse() 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
