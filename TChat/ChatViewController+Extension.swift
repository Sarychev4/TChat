//
//  ChatViewController+Extension.swift
//  TChat
//
//  Created by Артем Сарычев on 4.05.21.
//

import Foundation
import UIKit

extension ChatViewController {
    
    func observeMessages(){
        Api.Message.receiveMessage(from: Api.User.currentUserId, to: partnerId) { (message) in
            //print(message.id)
            self.messages.append(message)
            self.sortMessages()
        }
        
        Api.Message.receiveMessage(from: partnerId, to: Api.User.currentUserId) { (message) in
            //print(message.id)
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
        
        let micImg = UIImage(named: "mic")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        audioButton.setImage(micImg, for: .normal)
        audioButton.tintColor = .lightGray
        
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
        
        let leftBarButtonItem = UIBarButtonItem(customView: containerView)
        self.navigationItem.leftItemsSupplementBackButton = true //not allow to overriding the natural back button
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        // print(self.navigationItem.leftBarButtonItem)
        
        topLabel.textAlignment = .center
        topLabel.numberOfLines = 0
        
        let attributed = NSMutableAttributedString(string: partnerUsername + "\n", attributes: [.font : UIFont.systemFont(ofSize: 17), .foregroundColor : UIColor.black])
        
        attributed.append(NSAttributedString(string: "Dummy Text", attributes: [.font : UIFont.systemFont(ofSize: 13), .foregroundColor : UIColor.green]))
        topLabel.attributedText = attributed
        
        self.navigationItem.titleView = topLabel
        
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
//        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
//            handleVideoSelectedForUrl(videoUrl)
//        } else {
//            handleImageSelectedForInfo(info)
//        }
        handleImageSelectedForInfo(info)
    }
    
//    func handleVideoSelectedForUrl(_ url: URL){
//        //save video data
//        let videoNameUnicId = NSUUID().uuidString
//        StorageService.saveVideoMessage(url: url, id: videoNameUnicId, onSuccess: { (anyValue) in
//            if let dict = anyValue as? [String: Any] {
//                self.sendToFirebase(dict: dict)
//            }
//        }) { (errorMessage) in
//
//        }
//        self.picker.dismiss(animated: true, completion: nil)
//    }
    
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
        cell.playButton.isHidden = messages[indexPath.row].videoUrl == "" //hide play button if it is not video
        cell.configureCell(uid: Api.User.currentUserId, message: messages[indexPath.row], image: imagePartner)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0
        let message = messages[indexPath.row]
        let text = message.text
        if !text.isEmpty {
            height = text.estimateFrameForText(text).height + 60
        }
        
        let heightMessage = message.height
        let widthMessage = message.width
        if heightMessage != 0, widthMessage != 0 {
            height = CGFloat(heightMessage / widthMessage * 250)
        }
        
        return height
    }
    
    
}