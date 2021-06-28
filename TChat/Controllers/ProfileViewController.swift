//
//  ProfileTableViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 7.05.21.
//

import UIKit
import ProgressHUD

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        observeData()
    }
    
    func setupView() {
        setupAvatar()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setupAvatar(){
        avatar.layer.cornerRadius = 52
        avatar.clipsToBounds = true
        avatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker(){
        view.endEditing(true)
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func observeData() {
        Api.User.getUserInforSingleEvent(uid: Api.User.currentUserId) { (user) in
            self.usernameTextField.text = user.username
            self.titleTextField.text = user.title
            self.avatar.kf.setImage(with: URL(string: user.profileImageUrl)!)
        }
    }
    
    @IBAction func logoutBtnDidTapped(_ sender: Any) {
        Api.User.logOut()
    }
    
    @IBAction func saveBtnDidTapped(_ sender: Any) {
        ProgressHUD.show("Loading...")
        var dict = Dictionary<String, Any>()
        if let username = usernameTextField.text, !username.isEmpty {
            dict["username"] = username
        }
        
        if let title = titleTextField.text, !title.isEmpty {
            dict["title"] = title
        }
        
        Api.User.saveUserProfile(dict: dict, onSuccess: {
            if let img = self.image {
                StorageService.savePhotoProfile(image: img, uid: Api.User.currentUserId, onSuccess: {
                    ProgressHUD.showSuccess()
                }) { (errorMessage) in
                    ProgressHUD.showError(errorMessage)
                }
            } else {
                ProgressHUD.showSuccess()
                
            }
            
        }) { (errorMessage) in
            ProgressHUD.showError(errorMessage)
        }
    }

}

//MARK: - Avatar extension
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageSelected = info[UIImagePickerController.InfoKey.editedImage] as? UIImage{
            self.image = imageSelected
            avatar.image = imageSelected
        }
        
        if let imageOriginal = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            image = imageOriginal
            avatar.image = imageOriginal
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
