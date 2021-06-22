//
//  ChatViewController+Extension.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import Foundation
import UIKit
import AVFoundation
import Kingfisher

extension ChatViewController {
    
    func observeMessages(){
        print("receiveMessage(from")
        Api.Message.receiveMessage(from: Api.User.currentUserId, to: partnerId) { (message) in
            DispatchQueue.main.async {
                self.messages.append(message)
                self.sortMessages()
            }
        }
    }
    
    func sortMessages() {
        messages = messages.sorted(by: { $0.date < $1.date })
        if messages.count > 0 {
            lastMessageKey = messages.first!.id
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToBottom()
        }
    }
    
    func scrollToBottom(){
        if messages.count > 0 {
            let index = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: index, at: UITableView.ScrollPosition.bottom, animated: true)
        }
    }
    
    func setupPicker(){
        picker.delegate = self
    }
    
    func setupTableView() {
        tableView.separatorStyle = .none //clear line between cells
        tableView.tableFooterView = UIView() //Clear separate borders of messages??? //FOOTER VIEW FOR ALL TABLE
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.delegate = self
        tableView.dataSource = self
        
        if #available(iOS 10.0, *){
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(loadMore), for: .valueChanged)
    }
    
    @objc func loadMore(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            Api.Message.loadMore(lastMessageKey: self.lastMessageKey, from: Api.User.currentUserId, to: self.partnerId, onSuccess:  { (messagesArray, lastMessageKey) in
                if messagesArray.isEmpty{
                    self.refreshControl.endRefreshing()
                    return
                }
                self.messages.append(contentsOf: messagesArray)
                self.messages = self.messages.sorted(by: { $0.date < $1.date })
                self.lastMessageKey = lastMessageKey
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
                
            })
        }
    }
    
//    func setupInputContainer(){
////        let mediaImg = UIImage(named: "attachment_icon")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
////        mediaButton.setImage(mediaImg, for: .normal)
////        mediaButton.tintColor = .lightGray
//        
//        //        let micImg = UIImage(named: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
//        //        recordButton.setImage(micImg, for: .normal)
//        //        recordButton.tintColor = .lightGray
//        
//        setupInputTextView()
//        
//        //KeyBoard
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
//        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
//    }
    
    @objc func adjustForKeyboard(notification: Notification){
        let userInfo = notification.userInfo!
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            bottomConstraint.constant = 0
        } else {
            
            if #available(iOS 11.0 , *){
                bottomConstraint.constant = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
            } else {
                bottomConstraint.constant = keyboardViewEndFrame.height
            }
        }
        
        view.layoutIfNeeded()
        
    }
    
//    func setupInputTextView(){
//
//        inputTextView.delegate = self
//
//        placeholderLbl.isHidden = false
//
//        let placeholderX: CGFloat = self.view.frame.size.width / 75
//        let placeholderY: CGFloat = 0
//        let placeholderWidth: CGFloat = inputTextView.bounds.width - placeholderX
//        let placeholderHeight: CGFloat = inputTextView.bounds.height
//
//        let placeholderFontSize = self.view.frame.size.width / 25
//
//        placeholderLbl.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
//        placeholderLbl.text = "Write a message"
//        placeholderLbl.font = UIFont(name: "HelveticaNeue", size: placeholderFontSize)
//        placeholderLbl.textColor = .lightGray
//        placeholderLbl.textAlignment = .left
//
//        inputTextView.addSubview(placeholderLbl)
//
//
//    }
    
    func setupNavigationBar(){
        navigationItem.largeTitleDisplayMode = .never
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 18
        avatarImageView.clipsToBounds = true
        containerView.addSubview(avatarImageView)
          
        avatarImageView.kf.setImage(with: URL(string: partnerUser.profileImageUrl)!)
        self.observeActivity()
        
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
            status = "online"
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
        value["sender_id"] = Api.User.currentUserId 
        value["date"] = date
//        value["read"] = false
        value["isRead"] = false
        value["samples"] = samples
        value["recordLength"] = recordLength
        Api.Message.sendMessage(from: Api.User.currentUserId, to: partnerId, value: value)
    }
}

extension ChatViewController: UITextViewDelegate {
    
//    func textViewDidChange(_ textView: UITextView) {
//        let spacing = CharacterSet.whitespacesAndNewlines
//        if !textView.text.trimmingCharacters(in: spacing).isEmpty{
//            let text = textView.text.trimmingCharacters(in: spacing)
//            sendButton.isEnabled = true
//            sendButton.setTitleColor(.black, for: .normal)
//            placeholderLbl.isHidden = true
//        } else {
//            sendButton.isEnabled = false
//            sendButton.setTitleColor(.lightGray, for: .normal)
//            placeholderLbl.isHidden = false
//        }
//    }
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
//        cell.playButton.isHidden = messages[indexPath.row].text != "" //hide play button if it is not video or audio
        cell.isReadyToPlay = false
        cell.configureCell(uid: Api.User.currentUserId, message: messages[indexPath.row], image: currentUserImage, partnerName: partnerUsername, partnerImageUrl: partnerUser.profileImageUrl, currentUserName: Api.User.currentUserName)
        //cell.handleAudioPlay()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var height: CGFloat = 0
//        let message = messages[indexPath.row]
//        let text = message.text
//        let audioUrlText = message.audioUrl
//        if !text.isEmpty {
//            height = text.estimateFrameForText(text).height + 60
//        }else if text.isEmpty && !audioUrlText.isEmpty{
//            height = audioUrlText.estimateFrameForText(audioUrlText).height + 60
//    }
//
//        let heightMessage = message.height
//        let widthMessage = message.width
//        if heightMessage != 0, widthMessage != 0 {
//            height = CGFloat(heightMessage / widthMessage * 250)
//        }

        return 162
       // return 95
    }
    
    
}



// MARK: AudioEXtension
extension ChatViewController: AVAudioRecorderDelegate {
    func loadRecordingUI() {
        let micImg = UIImage(named: "microPhone")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        recordButton.setImage(micImg, for: .normal)
//        recordButton.tintColor = .lightGray
       // recordButton.backgroundColor = .blue
        recordButton.layer.cornerRadius = 24
       // recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
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
        samples = []
        let audioFileUrl = getAudioFileURL()
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            //startMetering()
            audioRecorder = try AVAudioRecorder(url: audioFileUrl, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
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
        print(samples)
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
    
    @objc func updateMeter() {
        guard let recorder = audioRecorder else { return }
        
        recorder.updateMeters()
        
        let dB = recorder.averagePower(forChannel: 0)
        let percentage: Float = pow(10, (0.05 * dB)) + 0.1
        
       // samples.append(percentage)
        let value = CGFloat(Double(String(format: "%.1f", percentage))!)
        samples.append(value)
         print("DB \(dB)")
        print("PERCENTAGE\(percentage)")
        print("ROUNDED\(String(format: "%.1f", percentage))")
    }
    
  
    
    func startMetering() {
        link = CADisplayLink(target: self, selector: #selector(updateMeter))
        link?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    func stopMetering() {
        link?.invalidate()
        link = nil
    }
    
    
    
    
}
