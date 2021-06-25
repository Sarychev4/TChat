//
//  ChatViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 30.04.21.
//

import UIKit
import MobileCoreServices
import AVFoundation

//import FirebaseAuth

class ChatViewController: UIViewController {
    
    @IBOutlet weak var bottomPanelView: UIView!
    
    var pulse: PulseAnimation?

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    //MARK: -AUDIO
    @IBOutlet weak var recordButton: UIButton!
    var buttonCenter: CGPoint = .zero
    var buttonY: CGFloat = .zero
    var buttonX: CGFloat = .zero
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var samples: [CGFloat] = []
    var cuttedInboxSamples: [CGFloat] = []
    var cuttedMessageSamples: [CGFloat] = []
    
    var link: CADisplayLink?
    
    var timer = Timer()
    //var timer2 = Timer()
    
    @IBOutlet weak var timerLabel: UILabel! //Send your voice message
    var minutes = 0
    var seconds = 0
    var fractions = 0
    var recordLength = 0.0 //sec
    var recordFractions = 0.0
    
   
    
    var currentUserImage: UIImage? 
    var avatarImageView: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
    var topLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    var partnerUsername: String!
    var partnerId: String!
    var partnerUser: User!
    
    var placeholderLbl = UILabel()
    var picker = UIImagePickerController()
    
    var messages = [Message]()
    
    var isActive = false
    var lastTimeOnline = ""
    
    var isRecording = false
    
    
    var refreshControl = UIRefreshControl()
    var lastMessageKey: String?
    
    var location: CGPoint = .zero
    
    var dialogId: String?
    var lastMessageId: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRecordingSession()
        setupPicker()
        setupNavigationBar()
        // setupInputContainer()
        setupTableView()
        observeMessages()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setupRecordingSession(){
        recordingSession = AVAudioSession.sharedInstance()
        
        do{
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    }else{
                        print("FAILED")
                    }
                }
            }
        } catch {
            print("FAILED TO RECORD")
        }
    }
    

    
    @IBAction func recordButtonTouchDownDidTapped(_ sender: UIButton) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.startRecording()
            self.showAnimation(below: self.recordButton.layer, numberOfPulse: Float.infinity, radius: 80, postion: sender.center)
//                timer2 = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
        //
            self.timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(self.UpdateTimer), userInfo: nil, repeats: true)
            //    leftCancelLabel.isHidden = false
        }
    }
    
        @IBAction func recordButtonTouchUpInsideDidTapped(_ sender: UIButton) {
            
            finishRecording(success: true)
            let gg = getAudioFileURL()
            handleAudioSendWith(url: gg)
            if let pulseBtn = self.pulse {
                stopAnimation(pulseAnimation: pulseBtn)
            }
            timer.invalidate()
//            timer2.invalidate()
            timerLabel.textColor = UIColor(hexString: "BFBFBF")
            timerLabel.text = "Send your voice message"
           // leftCancelLabel.isHidden = true
            recordLength = recordFractions / 100
            print("ДЛИНА ДОРОЖКИ \(recordFractions)")
            (minutes, seconds, fractions, recordFractions) = (0, 0, 0, 0.0)
                
        }
        @IBAction func recordButtonTouchDragExitDidTapped(_ sender: UIButton) {
            print("exit")
            finishRecording(success: true)
            let gg = getAudioFileURL()
            handleAudioSendWith(url: gg)
            if let pulseBtn = self.pulse {
                stopAnimation(pulseAnimation: pulseBtn)
            }
    
            timer.invalidate()
          //  timer2.invalidate()
            timerLabel.textColor = UIColor(hexString: "BFBFBF")
            timerLabel.text = "Send your voice message"
           // leftCancelLabel.isHidden = true
            recordLength = recordFractions / 100
            print("ДЛИНА ДОРОЖКИ \(recordFractions)")
            (minutes, seconds, fractions, recordFractions) = (0, 0, 0, 0.0)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
 
        if let lastMsgId = self.lastMessageId, let dialogId = self.dialogId {
                    Ref().databaseRoot.child("feedMessages").child(dialogId).child(lastMsgId).child("isRead").setValue(true)
                    Ref().databaseInbox.child(dialogId).child("isRead").setValue(true)
        
                }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        
    }
    
    //MARK: -TIMER
    @objc func UpdateTimer() {
        recordFractions += 1.0
        fractions += 1
        if fractions > 99 {
            seconds += 1
            fractions = 0
        }
        
        if seconds == 60{
            minutes += 1
            seconds = 0
        }
        
        let secondsString = seconds > 9 ? "\(seconds)" : "0\(seconds)"
        timerLabel.textColor = .black
        timerLabel.text = "·\(minutes):\(secondsString),\(fractions)"//String(format: "%.1f", counter)
    }
    
    //MARK: -PulseAnimation
    func showAnimation(below: CALayer, numberOfPulse:Float, radius: CGFloat, postion: CGPoint) {
        pulse = PulseAnimation(numberOfPulse: numberOfPulse, radius: radius, postion: postion)
        pulse!.animationDuration = 1.0
        pulse!.backgroundColor = #colorLiteral(red: 0.05282949957, green: 0.5737867104, blue: 1, alpha: 1)
        
        bottomPanelView.layer.insertSublayer(pulse!, below: below)
        print("showAnimation")
        print(postion)
    }
    
    func stopAnimation(pulseAnimation: PulseAnimation){
        pulseAnimation.removeFromSuperlayer()
    }
   
 
}


