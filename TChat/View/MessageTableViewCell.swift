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
    @IBOutlet weak var soundWaveView: AudioVisualizationView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var dateLabelLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateLabelRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profileNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameRightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var soundWaveLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var soundWaveRightConstraint: NSLayoutConstraint!

    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var bubbleRightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    

    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    var message: Message!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bubbleView.layer.cornerRadius = 15
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderWidth = 0.4
       
      //  textMessageLabel.numberOfLines = 0
       // photoMessage.layer.cornerRadius = 15
       // photoMessage.clipsToBounds = true
        profileImageView.layer.cornerRadius = 14
        profileImageView.clipsToBounds = true
        
      //  photoMessage.isHidden = true
        profileImageView.isHidden = false
        //textMessageLabel.isHidden = true
        activityIndicatorView.isHidden = true
     activityIndicatorView.stopAnimating()
        activityIndicatorView.style = .large
        
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
            bubbleView.layer.addSublayer(playerLayer!)
           // player?.play()
           // playButton.isHidden = true
        }
        
    }
    //MARK: - VIDEO PLAYER
    var observation: Any? = nil
    
    func handlePlay(){
        let videoUrl = message.videoUrl
        if videoUrl.isEmpty{
            return
        }
        
        if let url = URL(string: videoUrl){
            activityIndicatorView.isHidden = false
            activityIndicatorView.startAnimating()
            
            player = AVPlayer(url: url)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
          //  playerLayer?.frame = photoAudio.frame
            //playerLayer?.frame = photoMessage.frame
            observation = player?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            bubbleView.layer.addSublayer(playerLayer!)
            player?.play()
            playButton.isHidden = true
        }
    }
    //class func
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "status" {
//            let status: AVPlayer.Status = player!.status
//            switch (status) {
//            case AVPlayer.Status.readyToPlay:
//                activityIndicatorView.isHidden = true
//                activityIndicatorView.stopAnimating()
//                break
//            case AVPlayer.Status.unknown, AVPlayer.Status.failed:
//                break
//            }
//        }
//    }
    //---------
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileImageView.isHidden = true
       // photoMessage.isHidden = true
       // profileImage.isHidden = true
       // textMessageLabel.isHidden = true
        
       // photoAudio.isHidden = true
        
        
        
//        if observation != nil {
//            stopObservers()
//        }
        
        playerLayer?.removeFromSuperlayer()
        player?.pause()
//        playButton.isHidden = false
      //  playButton.backgroundColor = .black
     
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }

    func stopObservers(){
        player?.removeObserver(self, forKeyPath: "status")
        observation = nil
    }
    
    @objc func handleTap() {
        handleAudioPlay()
        if self.player?.rate == 0 {
            self.player!.play()
            //let pauseBtnImg = UIImage(named: "pause")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
           // playButton.setImage(pauseBtnImg, for: .normal)
        } else {
            self.player!.pause()
           // let playBtnImg = UIImage(named: "play")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            //playButton.setImage(playBtnImg, for: .normal)
        }
    }
    
    func configureCell(uid: String, message: Message, image: UIImage, partnerName: String?, partnerImage: UIImage, currentUserName: String ){
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))

        soundWaveView.addGestureRecognizer(tap)

        soundWaveView.isUserInteractionEnabled = true
        
       
        
        self.message = message
        let text = message.text
        let audioUrlText = message.audioUrl
        var samples = message.samples
        
//        var numbersFromMin = samples.sorted(by: <).prefix(7)
//        var numbersFromMax = samples.sorted(by: >).prefix(6)
//        var meters = numbersFromMin + numbersFromMax
        
        let imageAudio = UIImage(named: "Audio_line")
//            photoAudio.audioURL =  URL(string: audioUrlText)
     //   soundWaveView.image = imageAudio
     //   profileNameLabel.text = partnerName
    soundWaveView.isHidden = false
       // self.soundWaveView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2.0)
       // self.soundWaveView.frame.size.width = 162
        self.soundWaveView.meteringLevelBarWidth = 3.0
        self.soundWaveView.meteringLevelBarInterItem = 3.0
        self.soundWaveView.meteringLevelBarCornerRadius = 0.0
        self.soundWaveView.gradientStartColor = .blue
        self.soundWaveView.gradientEndColor = .black
        self.soundWaveView.audioVisualizationMode = .read
        self.soundWaveView.meteringLevels = samples //Array(meters)
        
        
        
        if uid == message.from {
            profileImageView.image = image
            profileImageView.isHidden = false
            
            profileNameLabel.text = currentUserName
           // profileNameLabel.backgroundColor = .red
            
            profileNameLeftConstraint.constant = 0
            profileNameRightConstraint.constant = 30
            
            profileNameLabel.textAlignment = .right
            
            bubbleLeftConstraint.constant = 230
            bubbleRightConstraint.constant = 16
            
          //  soundWaveLeftConstraint.constant = 99
          //  soundWaveRightConstraint.constant = 0
            
            dateLabelRightConstraint.constant = 30
            dateLabelLeftConstraint.constant = 0
            
            dateLabel.textAlignment = .right
           // dateLabel.backgroundColor = .red
        }else{
            
            profileImageView.image = partnerImage
            profileImageView.isHidden = true
            
            profileNameLabel.text = partnerName
           // profileNameLabel.backgroundColor = .green
            profileNameTopConstraint.constant = 8
            profileNameLeftConstraint.constant = 30
            profileNameRightConstraint.constant = 0
            profileNameLabel.textAlignment = .left
            
            bubbleLeftConstraint.constant = 16
            bubbleRightConstraint.constant = 230
            
         //   soundWaveLeftConstraint.constant = 0
         //   soundWaveRightConstraint.constant = 99
            
            
            
            dateLabelRightConstraint.constant = 0
            dateLabelLeftConstraint.constant = 30
            
          //  dateLabel.backgroundColor = .green
            dateLabel.textAlignment = .left
            
        }
        //            //bubbleView.backgroundColor = UIColor.systemGroupedBackground //groupTableViewBackground
        //            bubbleView.layer.borderColor = UIColor.clear.cgColor
        //            bubbleRightConstraint.constant = 8
        //            bubbleLeftConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleRightConstraint.constant
        //
        //        } else {
        //           // profileImage.isHidden = false
        //            bubbleView.backgroundColor = UIColor.white
        //
        //            bubbleView.layer.borderColor = UIColor.clear.cgColor
        //
        //            bubbleLeftConstraint.constant = 55
        //            bubbleRightConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleLeftConstraint.constant
        //        }
        
        
        
        
        bubbleView.layer.borderColor = UIColor.clear.cgColor
        let date = Date(timeIntervalSince1970: message.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLabel.text = dateString
        
       // textMessageLabel.isHidden = false
       // textMessageLabel.text = message.audioUrl
        
//        if !text.isEmpty {
//            textMessageLabel.isHidden = false
//            textMessageLabel.text = message.text
//
//            let widthValue = text.estimateFrameForText(text).width + 40
//
//            if widthValue < 75 {
//                widthConstraint.constant = 75
//            } else {
//                widthConstraint.constant = widthValue
//            }
//
//            dateLabel.textColor = .lightGray
//
//        } else if text.isEmpty && !audioUrlText.isEmpty{
//
//            textMessageLabel.isHidden = true
//            textMessageLabel.text = message.audioUrl
            
//             let thisBundle = Bundle(for: type(of: self))
//
//            let url = thisBundle.url(forResource: message.audioUrl, withExtension: "aiff")
//             self.photoAudio.audioURL = url
             
            
            
//            playButton.backgroundColor = UIColor(red: 5/255, green: 132/255, blue: 254/255, alpha: 1)
//            playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
//         //   widthConstraint.constant = 120
//            dateLabel.textColor = .black
          //  bubbleView.layer.borderColor = UIColor.clear.cgColor
//            let widthValue = audioUrlText.estimateFrameForText(audioUrlText).width + 40
//
//            if widthValue < 75 {
//                widthConstraint.constant = 75
//            } else {
//                widthConstraint.constant = widthValue - 40
//            }
    //    }else {


        //    photoMessage.isHidden = false
       //     photoMessage.loadImage(message.imageUrl)
            
     //       widthConstraint.constant = 250
           // dateLabel.textColor = .white
   //     }

//
        
        
        

        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


