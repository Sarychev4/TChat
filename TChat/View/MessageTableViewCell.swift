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
    // @IBOutlet weak var soundWaveView: AudioVisualizationView!
    var soundWaveView: AudioVisualizationView!
    var soundWaveViewLeft: AudioVisualizationView!
    
    
    
    @IBOutlet weak var soundLinesViewRight: MessageCurves!
    @IBOutlet weak var soundLinesViewLeft: MessageCurves!
    
    @IBOutlet weak var soundLinesViewRightReaded: MessageCurvesReaded!
    @IBOutlet weak var soundLinesViewLeftReaded: MessageCurvesReaded!
    
    
    @IBOutlet weak var containerForSoundLinesViewRightReaded: UIView!
    
    @IBOutlet weak var containerForSoundLinesViewLeftReaded: UIView!
    //var soundLinesViewRight: MessageCurves!
   // var soundLinesViewLeft: MessageCurves!
    @IBOutlet weak var containerForSoundLinesViewRightReadedBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var rightContainerForSoundWaveView: UIView!
    @IBOutlet weak var leftContainerForSoundWaveView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var timeAndDateLabel: UILabel!
    
    // @IBOutlet weak var recordLengthLabel: UILabel!
    
    @IBOutlet weak var profileNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var timeAndDateLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeAndDateLabelRightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var containerForSoundWaveViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerForSoundWaveViewRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var containerForSoundWaveViewWidth: NSLayoutConstraint!
    @IBOutlet weak var bubbleLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bubbleWidthConstraint: NSLayoutConstraint!
    
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
            
            playerLayer = AVPlayerLayer(player: player)
            print(" Начинаю ")
        }
        
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
                        self.player!.play()
                        let secs = Double(self.message.recordLength)
                        // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                       // self.soundWaveView.play(for: secs) //MARK:  -TIMEDURATION
                        // self.soundWaveViewLeft.play(for: secs)
                        // }
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
        
        //profileImageView.isHidden = true
        //player?.currentItem?.removeObserver(self, forKeyPath: KeyPath.PlayerItem.Status)
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
        print("PLAY SOUND")
        UIView.animate(withDuration: Double(self.message.recordLength)) {
            self.containerForSoundLinesViewRightReadedBottomConstraint.constant = 0
            self.rightContainerForSoundWaveView.layoutIfNeeded()
        }
       
        handleAudioPlay()
        //        if self.player?.rate == 0 {
        //            self.player!.play()
        //            let secs = Double(self.message.recordLength)
        //           // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
        //            self.soundWaveView.play(for: secs) //MARK:  -TIMEDURATION
        //            self.soundWaveViewLeft.play(for: secs)
        //          //  }
        //        } else {
        //            self.player!.pause()
        //        }
    }
    
    func configureCell(uid: String, message: Message, image: UIImage?, partnerName: String?, partnerImageUrl: String, currentUserName: String ){
        //stopObservers()
        self.message = message
        //let recordSeconds = message.recordLength
        // let text = message.text
        //let audioUrlText = message.audioUrl
        let samples = message.cuttedMessageSamples
        containerForSoundLinesViewRightReadedBottomConstraint.constant = containerForSoundLinesViewRightReaded.bounds.height
        containerForSoundLinesViewRightReaded.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let tapLeft = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        //self.soundLinesViewRight = MessageCurves(frame: CGRect(x: 0, y: 0, width: 34, height: self.rightContainerForSoundWaveView.bounds.height))
        self.soundLinesViewRight.array = samples
        self.soundLinesViewRight.backgroundColor = .clear
        
        self.soundLinesViewRightReaded.array = samples
        self.soundLinesViewRightReaded.backgroundColor = .clear
        self.rightContainerForSoundWaveView.addGestureRecognizer(tap)
        //rightContainerForSoundWaveView.addSubview(self.soundLinesViewRight)
        
        
        //self.soundLinesViewLeft = MessageCurves(frame: CGRect(x: 0, y: 0, width: 34, height: self.rightContainerForSoundWaveView.bounds.height))
        
        self.soundLinesViewLeft.array = samples
        self.soundLinesViewLeft.backgroundColor = .clear
        
        self.soundLinesViewLeftReaded.array = samples
        self.soundLinesViewLeftReaded.backgroundColor = .clear
        self.leftContainerForSoundWaveView.addGestureRecognizer(tapLeft)
       // leftContainerForSoundWaveView.addSubview(self.soundLinesViewLeft)
        
//        self.soundWaveView = AudioVisualizationView(frame: CGRect(x: -50, y: 0, width: 135, height: 135))
//        self.soundWaveView.meteringLevelBarWidth = 6.0
//        self.soundWaveView.meteringLevelBarInterItem = 6.0
//        self.soundWaveView.gradientStartColor = .blue
//        self.soundWaveView.backgroundColor = .white
//        self.soundWaveView.gradientEndColor = .white
//        self.soundWaveView.audioVisualizationMode = .read
//        self.soundWaveView.addGestureRecognizer(tap)
//        self.soundWaveView.isUserInteractionEnabled = true
//        self.soundWaveView.meteringLevels = samples
//        self.rightContainerForSoundWaveView.addSubview(self.soundWaveView)
//        self.soundWaveView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
        
        
//        self.soundWaveViewLeft = AudioVisualizationView(frame: CGRect(x: -50, y: 0, width: 135, height: 135))
//        self.soundWaveViewLeft.meteringLevelBarWidth = 6.0
//        self.soundWaveViewLeft.meteringLevelBarInterItem = 6.0
//        self.soundWaveViewLeft.gradientStartColor = .blue
//        self.soundWaveViewLeft.backgroundColor = .white
//        self.soundWaveViewLeft.gradientEndColor = .white
//        self.soundWaveViewLeft.audioVisualizationMode = .read
//        self.soundWaveViewLeft.addGestureRecognizer(tapLeft)
//        self.soundWaveViewLeft.isUserInteractionEnabled = true
//        self.soundWaveViewLeft.meteringLevels = samples
//        self.leftContainerForSoundWaveView.addSubview(self.soundWaveViewLeft)
//        self.soundWaveViewLeft.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
        
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
        timeAndDateLabel.text = "\(message.recordLength)sec · \(dateString)"
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}


