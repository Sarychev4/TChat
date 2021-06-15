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
    @IBOutlet weak var mediaButton: UIButton!
    var pulse: PulseAnimation?
    //    @IBOutlet weak var inputTextView: UITextView!
    //    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    //MARK: -AUDIO
    @IBOutlet weak var recordButton: UIButton!
    var buttonCenter: CGPoint = .zero
    var buttonY: CGFloat = .zero
    var buttonX: CGFloat = .zero
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var samples: [Float] = []
    var link: CADisplayLink?
    
    var timer = Timer()
    var timer2 = Timer()
    
    @IBOutlet weak var timerLabel: UILabel! //Send your voice message
    var minutes = 0
    var seconds = 0
    var fractions = 0
    var recordLength = 0 //sec
    
    @IBOutlet weak var leftCancelLabel: UILabel!
    
    var currentUserImage: UIImage?
    var imagePartner: UIImage! // image from users VC
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        leftCancelLabel.isHidden = true
        
        //Users permission for audio
        
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
        
        
        
        
        setupPicker()
        setupNavigationBar()
        // setupInputContainer()
        setupTableView()
        //observeMessages()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panButton(pan:)))
        recordButton.addGestureRecognizer(pan)
    }
    
    @objc func panButton(pan: UIPanGestureRecognizer){

        if pan.state == .began{
            buttonCenter = recordButton.center //store old btn center
            buttonY = recordButton.frame.origin.y
            buttonX = recordButton.frame.origin.x

        } else if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {

            recordButton.center = buttonCenter

//            if let pulseBtn = self.pulse {
//                stopAnimation(pulseAnimation: pulseBtn)
//            }

            finishRecording(success: true)
            let gg = getAudioFileURL()
            handleAudioSendWith(url: gg)
            if let pulseBtn = self.pulse {
                stopAnimation(pulseAnimation: pulseBtn)
            }
            timer.invalidate()
            timer2.invalidate()
            timerLabel.textColor = UIColor(hexString: "BFBFBF")
            timerLabel.text = "Send your voice message"
            leftCancelLabel.isHidden = true
            recordLength = seconds
            (minutes, seconds, fractions) = (0, 0, 0)

            leftCancelLabel.isHidden = true


            UIView.animate(withDuration: 0.1) {
                let micImg = UIImage(named: "microPhone")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                self.recordButton.setImage(micImg, for: .normal)
                self.recordButton.backgroundColor = .blue
            }
        } else {

            leftCancelLabel.isHidden = true

            if let pulseBtn = self.pulse {
                stopAnimation(pulseAnimation: pulseBtn)
            }
            self.location = pan.location(in: bottomPanelView)
            recordButton.center = location
            recordButton.frame.origin.y = buttonY

            print(recordButton.frame.origin.x)
            if recordButton.frame.origin.x < 250 {

                UIView.animate(withDuration: 0.1) {
                    let micImg = UIImage(named: "Trash")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    self.recordButton.setImage(micImg, for: .normal)
                    self.recordButton.backgroundColor = .red
                }

            }else{
                UIView.animate(withDuration: 0.1) {
                    let micImg = UIImage(named: "microPhone")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
                    self.recordButton.setImage(micImg, for: .normal)
                   // self.recordButton.backgroundColor = .blue
                }
            }

            if recordButton.frame.origin.x < bottomPanelView.bounds.width/2 - recordButton.frame.width/2 {
                recordButton.frame.origin.x = bottomPanelView.bounds.width/2 - recordButton.frame.width/2
            }

            if recordButton.frame.origin.x > buttonX{
                recordButton.frame.origin.x = buttonX
            }

        }
    }
    
    @IBAction func recordButtonTouchDownDidTapped(_ sender: UIButton) {
        startRecording()
        showAnimation(below: recordButton.layer, numberOfPulse: Float.infinity, radius: 80, postion: sender.center)
                timer2 = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateMeter), userInfo: nil, repeats: true)
        //
                timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(UpdateTimer), userInfo: nil, repeats: true)
                leftCancelLabel.isHidden = false
    }
    
        @IBAction func recordButtonTouchUpInsideDidTapped(_ sender: UIButton) {
            finishRecording(success: true)
            let gg = getAudioFileURL()
            handleAudioSendWith(url: gg)
            if let pulseBtn = self.pulse {
                stopAnimation(pulseAnimation: pulseBtn)
            }
            timer.invalidate()
            timer2.invalidate()
            timerLabel.textColor = UIColor(hexString: "BFBFBF")
            timerLabel.text = "Send your voice message"
            leftCancelLabel.isHidden = true
            recordLength = seconds
            (minutes, seconds, fractions) = (0, 0, 0)
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
            timer2.invalidate()
            timerLabel.textColor = UIColor(hexString: "BFBFBF")
            timerLabel.text = "Send your voice message"
            leftCancelLabel.isHidden = true
            recordLength = seconds
            (minutes, seconds, fractions) = (0, 0, 0)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    //MARK: -TIMER
    @objc func UpdateTimer() {
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
    
    //    @IBAction func sendButtonDidTapped(_ sender: Any) {
    //        if let text = inputTextView.text, text != "" {
    //            inputTextView.text = ""
    //            self.textViewDidChange(inputTextView)
    //            sendToFirebase(dict:["text": text as Any])
    //        }
    //    }
    
    @IBAction func mediaButtonDidTapped(_ sender: Any) {
        let alert = UIAlertController(title: "TChat", message: "Select source", preferredStyle: UIAlertController.Style.actionSheet)
        
        let camera = UIAlertAction(title: "Take a picture", style: UIAlertAction.Style.default) { (_) in
            if  UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                self.picker.sourceType = .camera
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }
        
        let library = UIAlertAction(title: "Choose an Image or Video", style: UIAlertAction.Style.default) { (_) in
            if  UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
                self.picker.sourceType = .photoLibrary
                self.picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
                // self.picker.mediaTypes = [String(kUTTypeImage)]//, String(kUTTypeMovie)]
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }
        
        let videoCamera = UIAlertAction(title: "Take a video", style: UIAlertAction.Style.default) { (_) in
            if  UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera){
                self.picker.sourceType = .camera
                self.picker.mediaTypes = [String(kUTTypeMovie)] //MobileCoreServices
                self.picker.videoExportPreset = AVAssetExportPresetPassthrough //AVFoundation
                self.picker.videoMaximumDuration = 30
                self.present(self.picker, animated: true, completion: nil)
            } else {
                print("Unavailable")
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        
        alert.addAction(camera)
        alert.addAction(library)
        alert.addAction(cancel)
        alert.addAction(videoCamera)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


