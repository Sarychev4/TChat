//
//  ChatViewController+Extension.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import Foundation
import UIKit
import AVFoundation

extension ChatViewController {
    
    func observeMessages(){
        Api.Message.receiveMessage(from: Api.User.currentUserId, to: partnerId) { (message) in
            print(message.id)
            self.messages.append(message)
            self.sortMessages()
        }
        
        Api.Message.receiveMessage(from: partnerId, to: Api.User.currentUserId) { (message) in
            print(message.id)
            self.messages.append(message)
            self.sortMessages()
        }
    }
    
    func sortMessages() {
        messages = messages.sorted(by: { $0.date < $1.date })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setupPicker(){
        picker.delegate = self
    }
    
    func setupTableView() {
        tableView.separatorStyle = .none //clear line between cells
        tableView.tableFooterView = UIView() //Clear separate borders of messages??? //FOOTER VIEW FOR ALL TABLE
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func setupInputContainer(){
        let mediaImg = UIImage(named: "attachment_icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        mediaButton.setImage(mediaImg, for: .normal)
        mediaButton.tintColor = .lightGray
        
        //        let micImg = UIImage(named: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        //        recordButton.setImage(micImg, for: .normal)
        //        recordButton.tintColor = .lightGray
        
        setupInputTextView()
    }
    
    func setupInputTextView(){
        
        inputTextView.delegate = self
        
        placeholderLbl.isHidden = false
        
        let placeholderX: CGFloat = self.view.frame.size.width / 75
        let placeholderY: CGFloat = 0
        let placeholderWidth: CGFloat = inputTextView.bounds.width - placeholderX
        let placeholderHeight: CGFloat = inputTextView.bounds.height
        
        let placeholderFontSize = self.view.frame.size.width / 25
        
        placeholderLbl.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
        placeholderLbl.text = "Write a message"
        placeholderLbl.font = UIFont(name: "HelveticaNeue", size: placeholderFontSize)
        placeholderLbl.textColor = .lightGray
        placeholderLbl.textAlignment = .left
        
        inputTextView.addSubview(placeholderLbl)
        
        
    }
    
    func setupNavigationBar(){
        navigationItem.largeTitleDisplayMode = .never
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatarImageView.image = imagePartner
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        containerView.addSubview(avatarImageView)
        
        if imagePartner != nil {
            avatarImageView.image = imagePartner
            self.observeActivity()
            self.observeMessages()
        } else {
            avatarImageView.loadImage(partnerUser.profileImageUrl) { (image) in
                self.imagePartner = image
                self.observeActivity()
                self.observeMessages()
            }
        }
        
        let leftBarButtonItem = UIBarButtonItem(customView: containerView)
        self.navigationItem.leftItemsSupplementBackButton = true //not allow to overriding the natural back button
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        // print(self.navigationItem.leftBarButtonItem)
        
        //MARK: -STATUS
        updateTopLabel(bool: false)
        self.navigationItem.titleView = topLabel
        
    }
    
    func updateTopLabel(bool: Bool){
        var status = ""
        if bool {
            status = "Active"
            if isRecording {
                status = "Recording..."
            }
        } else {
            status = "Last seen \(self.lastTimeOnline)"
        }
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 0
        
        let attributed = NSMutableAttributedString(string: partnerUsername + "\n", attributes: [.font : UIFont.systemFont(ofSize: 17), .foregroundColor : UIColor.black])
        
        attributed.append(NSAttributedString(string: status, attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor : UIColor.lightGray]))
        topLabel.attributedText = attributed
    }
    
    func observeActivity(){
        let ref = Ref().databaseIsOnline(uid: partnerUser.uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let snap = snapshot.value as? Dictionary<String, Any> {
                if let active = snap["online"] as? Bool {
                    self.isActive = active
                }
                
                if let latest = snap["latest"] as? Double {
                    self.lastTimeOnline = latest.convertDate()
                }
                
            }
            self.updateTopLabel(bool: self.isActive)
        }
        ref.observe(.childChanged) { (snapshot) in
            if let snap = snapshot.value {
                if snapshot.key == "online" {
                    self.isActive = snap as! Bool
                }
                if snapshot.key == "latest" {
                    let latest = snap as! Double
                    self.lastTimeOnline = latest.convertDate()
                }
                
                if snapshot.key == "recording" {
                    let recording = snap as! String
                    self.isRecording = recording == Api.User.currentUserId ? true : false
                }
                self.updateTopLabel(bool: self.isActive)
            }
        }
    }
    
    func sendToFirebase(dict: Dictionary<String, Any>){
        let date: Double = Date().timeIntervalSince1970
        var value = dict
        value["from"] = Api.User.currentUserId
        value["to"] = partnerId
        value["date"] = date
        value["read"] = true
        
        Api.Message.sendMessage(from: Api.User.currentUserId, to: partnerId, value: value)
        
        
        
    }
}

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let spacing = CharacterSet.whitespacesAndNewlines
        if !textView.text.trimmingCharacters(in: spacing).isEmpty{
            let text = textView.text.trimmingCharacters(in: spacing)
            sendButton.isEnabled = true
            sendButton.setTitleColor(.black, for: .normal)
            placeholderLbl.isHidden = true
        } else {
            sendButton.isEnabled = false
            sendButton.setTitleColor(.lightGray, for: .normal)
            placeholderLbl.isHidden = false
        }
    }
}


extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            let tempUrl = createTemporaryURLforVideoFile(url: videoUrl)
            handleVideoSelectedForUrl(tempUrl)
            //print(tempUrl.absoluteString)
        } else {
            handleImageSelectedForInfo(info)
        }
        
    }
    
    func handleVideoSelectedForUrl(_ url: URL){
        //save video data
        let videoNameUnicId = NSUUID().uuidString// + ".mov"
        
        StorageService.saveVideoMessage(url: url, id: videoNameUnicId, onSuccess: { (anyValue) in
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
            }
        }) { (errorMessage) in
            
        }
        self.picker.dismiss(animated: true, completion: nil)
    }
    //!!!!!!!!!!!!!
    func createTemporaryURLforVideoFile(url: URL) -> URL {
        /// Create the temporary directory.
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        /// create a temporary file for us to copy the video to.
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
        /// Attempt the copy.
        do {
            try FileManager().copyItem(at: url.absoluteURL, to: temporaryFileURL)
        } catch {
            print("There was an error copying the video file to the temporary location.")
        }
        
        return temporaryFileURL as URL
    }
    
    
    func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey : Any]){
        var selectedImageFromPicker: UIImage?
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            selectedImageFromPicker = imageSelected
            
        }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            selectedImageFromPicker = imageOriginal
        }
        
        //save photo data
        let imageNameUnicId = NSUUID().uuidString
        StorageService.savePhotoMessage(image: selectedImageFromPicker, id: imageNameUnicId, onSuccess: { (anyValue) in
            print(anyValue)
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
            }
        }) { (errorMessage) in
            
        }
        
        self.picker.dismiss(animated: true, completion: nil)
    }
    
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell") as! MessageTableViewCell
        cell.playButton.isHidden = messages[indexPath.row].text != "" //hide play button if it is not video or audio
        
        cell.configureCell(uid: Api.User.currentUserId, message: messages[indexPath.row], image: imagePartner)
        cell.handleAudioPlay()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let message = messages[indexPath.row]
        let text = message.text
        let audioUrlText = message.audioUrl
        if !text.isEmpty {
            height = text.estimateFrameForText(text).height + 60
        }else if text.isEmpty && !audioUrlText.isEmpty{
            height = audioUrlText.estimateFrameForText(audioUrlText).height + 60
    }

        let heightMessage = message.height
        let widthMessage = message.width
        if heightMessage != 0, widthMessage != 0 {
            height = CGFloat(heightMessage / widthMessage * 250)
        }

        return height
       // return 95
    }
    
    
}



// MARK: AudioEXtension
extension ChatViewController: AVAudioRecorderDelegate {
    func loadRecordingUI() {
        let micImg = UIImage(named: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        recordButton.setImage(micImg, for: .normal)
        recordButton.tintColor = .lightGray
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
    }
    
    @objc func recordTapped(){
        
        if audioRecorder == nil {
            startRecording()
            
            if !isRecording {
                Api.User.recording(from: Api.User.currentUserId, to: partnerUser.uid)
                isRecording = true
            } else {
                timer.invalidate()
            }
            
            timerRecording()
            
        } else {
            
            finishRecording(success: true)
            let gg = getAudioFileURL()
            handleAudioSendWith(url: gg)
            //getAudioFileURL()
        }
    }
    
    func timerRecording(){
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {(t) in
            Api.User.recording(from: Api.User.currentUserId, to: "")
            self.isRecording = false
        })
    }
    
    func startRecording(){
        let audioFileUrl = getAudioFileURL()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            
            audioRecorder = try AVAudioRecorder(url: audioFileUrl, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            //            let micImgStop = UIImage(named: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            //            recordButton.setImage(micImgStop, for: .normal)
            recordButton.tintColor = .red
            //recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getAudioFileURL() -> URL {
        return getDocumentsDirectory().appendingPathComponent("rec.m4a")
    }
    
    func finishRecording(success: Bool) {
        
        audioRecorder.stop()
        
        audioRecorder = nil
        
        if success {
            // recordButton.setTitle("Tap to Re-record", for: .normal)
            recordButton.tintColor = .lightGray
        } else {
            //recordButton.setTitle("Tap to Record", for: .normal)
            // recording failed :(
            recordButton.tintColor = .green
            print("RECORDING FAIED")
        }
        
    }
    
    //UPLoAD FILE TO FIREBASE STORAGE
    func handleAudioSendWith(url: URL) {
        
        let fileName = NSUUID().uuidString + ".m4a"
        StorageService.saveAudioMessage(url: url, id: fileName, onSuccess: {(anyValue) in
            if let dict = anyValue as? [String: Any] {
                self.sendToFirebase(dict: dict)
            }
        }) { (errorMessage) in
            
        }
        
        
    }
    
    
    
    
}
