//
//  MessageTableViewCell.swift
//  TChat
//
//  Created by Артем Сарычев on 1.05.21.
//

import UIKit
import AVFoundation
import FDWaveformView
import SoundWave

class MessageTableViewCell: UITableViewCell {

    
    @IBOutlet weak var bubbleView: UIView!
    // @IBOutlet weak var soundWaveView: AudioVisualizationView!
    var soundWaveView: AudioVisualizationView!
    var soundWaveViewLeft: AudioVisualizationView!
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
    

    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    var message: Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        rightContainerForSoundWaveView.clipsToBounds = true
        leftContainerForSoundWaveView.clipsToBounds = true
        //bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth = 0.4
        profileImageView.layer.cornerRadius = 14
        profileImageView.clipsToBounds = true
        profileImageView.isHidden = false
        activityIndicatorView.isHidden = true
     activityIndicatorView.stopAnimating()
        activityIndicatorView.style = .large
        
      //  textMessageLabel.numberOfLines = 0
       // photoMessage.layer.cornerRadius = 15
       // photoMessage.clipsToBounds = true
        
        
      //  photoMessage.isHidden = true
        
        //textMessageLabel.isHidden = true
        
        
       // photoAudio.layer.cornerRadius = 5
        //photoAudio.clipsToBounds = true
        
    }
    
   
    //MARK: - AUDIO PLAYER
    func handleAudioPlay(){
        let audioUrl = message.audioUrl
        if audioUrl.isEmpty{
            return
        }

       // player = AVPlayer(url: audioUrl)
        if let url = URL(string: audioUrl){
//            activityIndicatorView.isHidden = false
//            activityIndicatorView.startAnimating()
            
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            //playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
           // playerLayer?.frame = photoAudio.frame
           // playerLayer?.frame = photoMessage.frame
           // observation = player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            //-----bubbleView.layer.addSublayer(playerLayer!)
           // player?.play()
           // playButton.isHidden = true
        }
        
    }
    //MARK: - VIDEO PLAYER
//    var observation: Any? = nil
//
//    func handlePlay(){
//        let videoUrl = message.videoUrl
//        if videoUrl.isEmpty{
//            return
//        }
//
//        if let url = URL(string: videoUrl){
//            activityIndicatorView.isHidden = false
//            activityIndicatorView.startAnimating()
//
//            player = AVPlayer(url: url)
//            playerLayer = AVPlayerLayer(player: player)
//            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
//          //  playerLayer?.frame = photoAudio.frame
//            //playerLayer?.frame = photoMessage.frame
//            observation = player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
//            bubbleView.layer.addSublayer(playerLayer!)
//            player?.play()
//            playButton.isHidden = true
//        }
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        //profileImageView.isHidden = true
        
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
        if self.player?.rate == 0 {
            self.player!.play()
            let secs = Double(self.message.recordLength)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            self.soundWaveView.play(for: secs) //MARK:  -TIMEDURATION
               // self.soundWaveViewLeft.play(for: secs)
            }
        } else {
            self.player!.pause()
        }
    }
    
    func configureCell(uid: String, message: Message, image: UIImage?, partnerName: String?, partnerImage: UIImage, currentUserName: String ){
        self.message = message
//let recordSeconds = message.recordLength
       // let text = message.text
        //let audioUrlText = message.audioUrl
        let samples = message.samples
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let tapLeft = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            
            self.soundWaveView = AudioVisualizationView(frame: CGRect(x: -50, y: 0, width: 135, height: 135))
          //rightContainerForSoundWaveView.frame.width/2 - 75
            //rightContainerForSoundWaveView.frame.height/2 - 16
            self.soundWaveView.meteringLevelBarWidth = 6.0
            self.soundWaveView.meteringLevelBarInterItem = 6.0
    //        self.soundWaveView.meteringLevelBarCornerRadius = 0.0
            self.soundWaveView.gradientStartColor = .blue
            self.soundWaveView.backgroundColor = .white
            self.soundWaveView.gradientEndColor = .white
            self.soundWaveView.audioVisualizationMode = .read
            self.soundWaveView.addGestureRecognizer(tap)
            self.soundWaveView.isUserInteractionEnabled = true
            self.soundWaveView.meteringLevels = samples//[0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3,0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3 ]//samples //Array(meters)
            self.rightContainerForSoundWaveView.addSubview(self.soundWaveView)
        //self.leftContainerForSoundWaveView.addSubview(self.soundWaveView)
            //self.bubbleView.addSubview(self.soundWaveView)
            self.soundWaveView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
//        }
        

        self.soundWaveViewLeft = AudioVisualizationView(frame: CGRect(x: -50, y: 0, width: 135, height: 135))
      //rightContainerForSoundWaveView.frame.width/2 - 75
        //rightContainerForSoundWaveView.frame.height/2 - 16
        self.soundWaveViewLeft.meteringLevelBarWidth = 6.0
        self.soundWaveViewLeft.meteringLevelBarInterItem = 6.0
//        self.soundWaveView.meteringLevelBarCornerRadius = 0.0
        self.soundWaveViewLeft.gradientStartColor = .blue
        self.soundWaveViewLeft.backgroundColor = .white
        self.soundWaveViewLeft.gradientEndColor = .white
        self.soundWaveViewLeft.audioVisualizationMode = .read
        self.soundWaveViewLeft.addGestureRecognizer(tapLeft)
        self.soundWaveViewLeft.isUserInteractionEnabled = true
        self.soundWaveViewLeft.meteringLevels = samples//[0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3,0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3, 0.9, 0.1, 0.3 ]//samples //Array(meters)
        
    self.leftContainerForSoundWaveView.addSubview(self.soundWaveViewLeft)
        //self.bubbleView.addSubview(self.soundWaveView)
        self.soundWaveViewLeft.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)
        
//        recordLengthLabel.text = "\(message.recordLength)sec"
        
        
        
//        var numbersFromMin = samples.sorted(by: <).prefix(7)
//        var numbersFromMax = samples.sorted(by: >).prefix(6)
//        var meters = numbersFromMin + numbersFromMax
        
        //let imageAudio = UIImage(named: "Audio_line")
//            photoAudio.audioURL =  URL(string: audioUrlText)
     //   soundWaveView.image = imageAudio
     //   profileNameLabel.text = partnerName
    //soundWaveView.isHidden = false
       // self.soundWaveView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0)
        
        
        
        
        
        
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

          //  soundWaveLeftConstraint.constant = 99
          //  soundWaveRightConstraint.constant = 0

            timeAndDateLabelRightConstraint.constant = 50
           // dateLabelLeftConstraint.constant = 0

            timeAndDateLabel.textAlignment = .right
           // dateLabel.backgroundColor = .red
//
//            containerForSoundWaveViewLeftConstraint.constant = bubbleView.frame.width - 34
           // containerForSoundWaveViewRightConstraint.constant = 0
        }else{
//
            leftContainerForSoundWaveView.isHidden = false
            rightContainerForSoundWaveView.isHidden = true
            profileImageView.image = partnerImage
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
//
//            containerForSoundWaveViewLeftConstraint.constant = 0
            //containerForSoundWaveViewRightConstraint.constant = bubbleView.frame.width - 34
//
        }
       
        
        
        
        
        bubbleView.layer.borderColor = UIColor.clear.cgColor
        let date = Date(timeIntervalSince1970: message.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        timeAndDateLabel.text = "\(message.recordLength)sec · \(dateString)"
        //        recordLengthLabel.text = "\(message.recordLength)sec"
//

    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


