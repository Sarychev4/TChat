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
            }
        } else {
            self.player!.pause()
        }
    }
    //MARK: - AUDIO PLAYER
    func handleAudioPlay(){
        guard let lastMessage = inbox.lastMessage else { return }
        let audioUrl = lastMessage.audioUrl
        if audioUrl.isEmpty{
            return
        }

       // player = AVPlayer(url: audioUrl)
        if let url = URL(string: audioUrl){
            
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
         
        }
        
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
       
        avatar.loadImage(opponent.profileImageUrl)
        
        let isLastMessageMine = lastMessage.senderId == uid
        if isLastMessageMine {
            self.messageAvatar.image = currentImage
        } else {
            self.messageAvatar.loadImage(opponent.profileImageUrl)
        }
        
        usernameLbl.text = opponent.username
        let date = Date(timeIntervalSince1970: lastMessage.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLbl.text = dateString
        
        guard let samples = inbox.lastMessage?.samples else { return }
        self.inboxSoundWaveView.meteringLevelBarWidth = 3.0
        self.inboxSoundWaveView.meteringLevelBarInterItem = 3.0
        self.inboxSoundWaveView.meteringLevelBarCornerRadius = 0.0
        self.inboxSoundWaveView.gradientStartColor = .blue
        self.inboxSoundWaveView.gradientEndColor = .white
        self.inboxSoundWaveView.audioVisualizationMode = .read
        self.inboxSoundWaveView.meteringLevels = samples
        
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
