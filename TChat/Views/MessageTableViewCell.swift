//
//  MessageTableViewCell.swift
//  TChat
//
//  Created by Артем Сарычев on 1.05.21.
//

import UIKit
import AVFoundation
import SoundWave

class MessageTableViewCell: UITableViewCell {
    private struct KeyPath {
        
        struct PlayerItem {
            static let Status = "status"
        }
    }
    
    @IBOutlet weak var bubbleView: UIView!
    
    var soundWaveView: AudioVisualizationView!
    var soundWaveViewLeft: AudioVisualizationView!
    
    @IBOutlet weak var soundLinesViewRight: MessageCurves!
    @IBOutlet weak var soundLinesViewLeft: MessageCurves!
    
    @IBOutlet weak var soundLinesViewRightReaded: MessageCurves!
    @IBOutlet weak var soundLinesViewLeftReaded: MessageCurves!
    
    @IBOutlet weak var containerForSoundLinesViewRightReaded: UIView!
    @IBOutlet weak var containerForSoundLinesViewLeftReaded: UIView!
    
    @IBOutlet weak var containerForSoundLinesViewRightReadedBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerForSoundLinesViewLeftReadedBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightContainerForSoundWaveView: UIView!
    @IBOutlet weak var leftContainerForSoundWaveView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var timeAndDateLabel: UILabel!
    
    @IBOutlet weak var profileNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeAndDateLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeAndDateLabelRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    
    //var observation: Any? = nil
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isReadyToPlay: Bool?
    
    var message: Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightContainerForSoundWaveView.clipsToBounds = true
        leftContainerForSoundWaveView.clipsToBounds = true
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth = 0.4
        profileImageView.layer.cornerRadius = 14
        profileImageView.clipsToBounds = true
        profileImageView.isHidden = false
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
        activityIndicatorView.style = .large
        
    }
    
    
    //MARK: - AUDIO PLAYER
    func handleAudioPlay(){
        
        let audioUrl = message.audioUrl
        if audioUrl.isEmpty{
            return
        }
        
        if let url = URL(string: audioUrl) {
            player?.currentItem?.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status)
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
            playerItem.addObserver(self, forKeyPath: KeyPath.PlayerItem.Status, options: [.initial, .new], context: nil)
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
             
            playerLayer = AVPlayerLayer(player: player)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        self.containerForSoundLinesViewRightReadedBottomConstraint.constant = rightContainerForSoundWaveView.bounds.height
        self.containerForSoundLinesViewLeftReadedBottomConstraint.constant = leftContainerForSoundWaveView.bounds.height
        self.rightContainerForSoundWaveView.layoutIfNeeded()
        self.leftContainerForSoundWaveView.layoutIfNeeded()
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Player Item Observers
        
        if keyPath == KeyPath.PlayerItem.Status {
            if let statusInt = change?[.newKey] as? Int, let status = AVPlayerItem.Status(rawValue: statusInt) {
                switch status {
                case .unknown:
                    break
                case .readyToPlay:
                    if self.player?.rate == 0 {
                       
                        let duration: Double = Double(self.message.recordLength)

                        UIView.animate(withDuration: duration + 0.5, animations: {
                            self.containerForSoundLinesViewRightReadedBottomConstraint.constant = 0
                            self.containerForSoundLinesViewLeftReadedBottomConstraint.constant = 0
                            self.rightContainerForSoundWaveView.layoutIfNeeded()
                            self.leftContainerForSoundWaveView.layoutIfNeeded()
                        }, completion: { (finished: Bool) in
               
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
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
     
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }
    
    //    func stopObservers(){
    //        player?.removeObserver(self, forKeyPath: "status")
    //        observation = nil
    //    }
    
    @objc func handleTap() {
        handleAudioPlay()
    }
    
    func configureCell(uid: String, message: Message, image: UIImage?, partnerName: String?, partnerImageUrl: String, currentUserName: String ){
        //stopObservers()
        self.message = message
        //let recordSeconds = message.recordLength
        // let text = message.text
        //let audioUrlText = message.audioUrl
        let samples = message.cuttedMessageSamples
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let tapLeft = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        self.soundLinesViewRight.samples = samples
        self.soundLinesViewRight.backgroundColor = .clear
        
        self.soundLinesViewRightReaded.samples = samples
        self.soundLinesViewRightReaded.backgroundColor = .clear
        
        containerForSoundLinesViewRightReadedBottomConstraint.constant = rightContainerForSoundWaveView.bounds.height
        containerForSoundLinesViewRightReaded.clipsToBounds = true
        self.rightContainerForSoundWaveView.addGestureRecognizer(tap)
        
        self.soundLinesViewLeft.samples = samples
        self.soundLinesViewLeft.backgroundColor = .clear
        
        self.soundLinesViewLeftReaded.samples = samples
        self.soundLinesViewLeftReaded.backgroundColor = .clear
        
        containerForSoundLinesViewLeftReadedBottomConstraint.constant = leftContainerForSoundWaveView.bounds.height
        containerForSoundLinesViewLeftReaded.clipsToBounds = true
        self.leftContainerForSoundWaveView.addGestureRecognizer(tapLeft)

        if uid == message.senderId { //my
            if let currentUserImg = image {
                profileImageView.image = currentUserImg
            }
            leftContainerForSoundWaveView.isHidden = true
            rightContainerForSoundWaveView.isHidden = false
            
            profileImageView.isHidden = false
            profileNameLabel.text = currentUserName
            
            profileNameTopConstraint.constant = 32
            profileNameLeftConstraint.constant = 0
            profileNameRightConstraint.constant = 50
            
            profileNameLabel.textAlignment = .right
            
            bubbleLeftConstraint.constant = 54
            bubbleRightConstraint.constant = 16
            
            timeAndDateLabelRightConstraint.constant = 50
            timeAndDateLabel.textAlignment = .right
            
        }else{
            
            leftContainerForSoundWaveView.isHidden = false
            rightContainerForSoundWaveView.isHidden = true
            
            profileImageView.kf.setImage(with: URL(string: partnerImageUrl))
            profileImageView.isHidden = true
            
            profileNameLabel.text = partnerName
            
            profileNameTopConstraint.constant = 0
            profileNameLeftConstraint.constant = 50
            profileNameRightConstraint.constant = 0
            profileNameLabel.textAlignment = .left
            
            bubbleLeftConstraint.constant = 16
            bubbleRightConstraint.constant = 50
            
            timeAndDateLabelLeftConstraint.constant = 50
            timeAndDateLabel.textAlignment = .left
            
        }
        
        bubbleView.layer.borderColor = UIColor.clear.cgColor
        let date = Date(timeIntervalSince1970: message.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        timeAndDateLabel.text = "\(String(format: "%.0f", message.recordLength))sec · \(dateString)"
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


