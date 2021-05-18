//
//  MessageTableViewCell.swift
//  TChat
//
//  Created by Артем Сарычев on 1.05.21.
//

import UIKit
import AVFoundation

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var textMessageLabel: UILabel!
    
    @IBOutlet weak var photoAudio: UIImageView!
    @IBOutlet weak var photoMessage: UIImageView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
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
       
        textMessageLabel.numberOfLines = 0
        photoMessage.layer.cornerRadius = 15
        photoMessage.clipsToBounds = true
        profileImage.layer.cornerRadius = 16
        profileImage.clipsToBounds = true
        
        photoMessage.isHidden = true
        profileImage.isHidden = false
        textMessageLabel.isHidden = true
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
        activityIndicatorView.style = .large
        
        photoAudio.layer.cornerRadius = 5
        photoAudio.clipsToBounds = true
        
    }
    
    @IBAction func playBtnDidTapped(_ sender: Any) {
        //handlePlay()
//        handleAudioPlay()
        if player?.rate == 0 {
            player!.play()
            let pauseBtnImg = UIImage(named: "pause")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            playButton.setImage(pauseBtnImg, for: .normal)
        } else {
            player!.pause()
            let playBtnImg = UIImage(named: "play")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            playButton.setImage(playBtnImg, for: .normal)
        }
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
            playerLayer?.frame = photoMessage.frame
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
            playerLayer?.frame = photoMessage.frame
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
        photoMessage.isHidden = true
        profileImage.isHidden = true
        textMessageLabel.isHidden = true
        
        photoAudio.isHidden = true
        
//        if observation != nil {
//            stopObservers()
//        }
        playerLayer?.removeFromSuperlayer()
        player?.pause()
        playButton.isHidden = false
      //  playButton.backgroundColor = .black
     
        activityIndicatorView.isHidden = true
        activityIndicatorView.stopAnimating()
    }

    func stopObservers(){
        player?.removeObserver(self, forKeyPath: "status")
        observation = nil
    }
    func configureCell(uid: String, message: Message, image: UIImage){
       self.message = message
       let text = message.text
        let audioUrlText = message.audioUrl
        
        textMessageLabel.isHidden = false
        textMessageLabel.text = message.audioUrl
        
        if !text.isEmpty {
            textMessageLabel.isHidden = false
            textMessageLabel.text = message.text

            let widthValue = text.estimateFrameForText(text).width + 40

            if widthValue < 75 {
                widthConstraint.constant = 75
            } else {
                widthConstraint.constant = widthValue
            }

            dateLabel.textColor = .lightGray
            
        } else if text.isEmpty && !audioUrlText.isEmpty{
            
            textMessageLabel.isHidden = true
//            textMessageLabel.text = message.audioUrl
            
            let imageAudio = UIImage(named: "Audio_line")
            photoAudio.image = imageAudio
            photoAudio.isHidden = false
            
            playButton.backgroundColor = UIColor(red: 5/255, green: 132/255, blue: 254/255, alpha: 1)
            playButton.layer.cornerRadius = 0.5 * playButton.bounds.size.width
            widthConstraint.constant = 120
            dateLabel.textColor = .black
            bubbleView.layer.borderColor = UIColor.clear.cgColor
//            let widthValue = audioUrlText.estimateFrameForText(audioUrlText).width + 40
//
//            if widthValue < 75 {
//                widthConstraint.constant = 75
//            } else {
//                widthConstraint.constant = widthValue - 40
//            }
        }else {


            photoMessage.isHidden = false
            photoMessage.loadImage(message.imageUrl)
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            widthConstraint.constant = 250
            dateLabel.textColor = .white
        }

        if uid == message.from {
            //bubbleView.backgroundColor = UIColor.systemGroupedBackground //groupTableViewBackground
            bubbleView.layer.borderColor = UIColor.clear.cgColor
            bubbleRightConstraint.constant = 8
            bubbleLeftConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleRightConstraint.constant
           
        } else {
            profileImage.isHidden = false
            bubbleView.backgroundColor = UIColor.white
            profileImage.image = image
            bubbleView.layer.borderColor = UIColor.clear.cgColor

            bubbleLeftConstraint.constant = 55
            bubbleRightConstraint.constant = UIScreen.main.bounds.width - widthConstraint.constant - bubbleLeftConstraint.constant
        }
        
        let date = Date(timeIntervalSince1970: message.date)
        let dateString = timeAgoSinceDate(date, currentDate: Date(), numericDates: true)
        dateLabel.text = dateString
        

        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


