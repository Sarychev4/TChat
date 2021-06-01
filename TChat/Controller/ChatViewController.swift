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
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    //MARK: -AUDIO
    @IBOutlet weak var recordButton: UIButton!
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var samples: [Float] = []
    var link: CADisplayLink?
    
    var currentUserImage: UIImage!
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
    var timer = Timer()
    
    var refreshControl = UIRefreshControl()
    var lastMessageKey: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        // Do any additional setup after loading the view.
    }
    
    @IBAction func recordButtonTouchDownDidTapped(_ sender: UIButton) {
        startRecording()
        showAnimation(below: recordButton.layer, numberOfPulse: Float.infinity, radius: 80, postion: sender.center)
    }
    
    @IBAction func recordButtonTouchUpInsideDidTapped(_ sender: UIButton) {
        finishRecording(success: true)
        let gg = getAudioFileURL()
        handleAudioSendWith(url: gg)
        if let pulseBtn = self.pulse {
            stopAnimation(pulseAnimation: pulseBtn)
        }
    }
    @IBAction func recordButtonTouchDragExitDidTapped(_ sender: UIButton) {
        print("exit")
        finishRecording(success: true)
        let gg = getAudioFileURL()
        handleAudioSendWith(url: gg)
        if let pulseBtn = self.pulse {
            stopAnimation(pulseAnimation: pulseBtn)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
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
    
    @IBAction func sendButtonDidTapped(_ sender: Any) {
        if let text = inputTextView.text, text != "" {
            inputTextView.text = ""
            self.textViewDidChange(inputTextView)
            sendToFirebase(dict:["text": text as Any])
        }
    }
    
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


