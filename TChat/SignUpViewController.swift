//
//  SignUpViewController.swift
//  TChat
//
//  Created by Артем Сарычев on 26.04.21.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import ProgressHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var titleTextLabel: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    
    @IBOutlet weak var fullnameContainerView: UIView!
    @IBOutlet weak var fullnameTextField: UITextField!
    
    @IBOutlet weak var emailContainerView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordContainerView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    var image: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI(){
        
        setupTitleLabel()
        setupAvatar()
        setupFullNameTextField()
        setupEmailTextField()
        setupPasswordTextField()
        setupSignUpButton()
        setupSignInButton()
        
    }
    
    @IBAction func dissmissAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func validateFields(){
        guard let username = self.fullnameTextField.text, !username.isEmpty else {
            ProgressHUD.showError("Please enter an username")
            return
        }
        
        guard let email = self.emailTextField.text, !email.isEmpty else {
            ProgressHUD.showError("Please enter an email address")
            return
        }
        
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            ProgressHUD.showError("Please enter a password")
            return
        }
    }
    
    //MARK: - Auth with FireBase
    @IBAction func signUpButtonDidTapped(_ sender: Any) {
        
        //Dismiss keyboard when user touch view
        self.view.endEditing(true)
        
        self.validateFields()
        
        guard let imageSelected = self.image else {
            print("Avatar is nil")
            ProgressHUD.showError("Please choose your profile image")
            return
        }
        //Convert data
        guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
            return
        }
        
        Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (authDataResult, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let authData = authDataResult {
                print(authData.user.email ?? "Empty")
                var dict: Dictionary<String, Any> = [
                    "uid": authData.user.uid,
                    "email": authData.user.email ?? "Empty",
                    "username": self.fullnameTextField.text,
                    "profileImageUrl": "",
                    "status": "Default status"
                ]
                
                let storageRef = Storage.storage().reference(forURL: "gs://tchat-8865f.appspot.com")
                let storageProfileRef = storageRef.child("profile").child(authData.user.uid)
                
                //Put Data in storage
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                //Put Data in storage
                storageProfileRef.putData(imageData, metadata: metadata) { (storageMetaData, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                        return
                    }
                    
                    //Download image to upload in FireBase Database
                    storageProfileRef.downloadURL(completion: { (url, error) in
                        if let metaImageUrl = url?.absoluteString { //Convert to String
                            dict["profileImageUrl"] = metaImageUrl
                            
                            
                            Database.database().reference().child("users")
                                .child(authData.user.uid)
                                .updateChildValues(dict, withCompletionBlock: {
                                    (error, ref) in
                                    if error == nil {
                                        print("Done")
                                    }
                                })
                            
                        }
                    })
                }
                
                
            }
        }
    }
}
