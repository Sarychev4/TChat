//
//  SignUpViewController+UI.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import UIKit
import ProgressHUD

extension SignUpViewController {
    
    
    func setupTitleLabel(){
        
        let title = "Sign Up"
        let attributedText = NSMutableAttributedString(string: title, attributes:
                                                        [NSAttributedString.Key.font : UIFont.init(name: "SFProDisplay-Regular", size: 28)!,
                                                         NSAttributedString.Key.foregroundColor : UIColor.black])
        titleTextLabel.attributedText = attributedText
        
    }
    
    func setupAvatar(){
        avatar.image = UIImage(named: "ChoosePhoto")
        avatar.layer.cornerRadius = 38
        avatar.clipsToBounds = true
        avatar.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentPicker))
        avatar.addGestureRecognizer(tapGesture)
    }
    
    @objc func presentPicker(){
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    func setupFullNameTextField(){
        
        nameContainerView.layer.borderWidth = 1
        nameContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        nameContainerView.layer.cornerRadius = 8
        nameContainerView.clipsToBounds = true
        nameContainerView.backgroundColor = UIColor(hexString: "F5F5F5")
        
        nameTextField.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Name", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])

        nameTextField.attributedPlaceholder = placeholderAttr
        nameTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    
    func setupEmailTextField(){
        
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        emailContainerView.layer.cornerRadius = 8
        emailContainerView.clipsToBounds = true
        emailContainerView.backgroundColor = UIColor(hexString: "F5F5F5")
        
        emailTextField.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "E-mail", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        emailTextField.attributedPlaceholder = placeholderAttr
        emailTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    
    func setupPasswordTextField(){
        passwordContainerView.layer.borderWidth = 1
        passwordContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        passwordContainerView.layer.cornerRadius = 8
        passwordContainerView.clipsToBounds = true
        passwordContainerView.backgroundColor = UIColor(hexString: "F5F5F5")
        
        passwordTextField.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Password (6+ Characters)", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        passwordTextField.attributedPlaceholder = placeholderAttr
        passwordTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
        
    }
    
    func setupSignUpButton(){
        
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signUpButton.backgroundColor = .systemBlue
        signUpButton.layer.cornerRadius = 8
        signUpButton.clipsToBounds = true
        signUpButton.setTitleColor(.white, for: UIControl.State.normal)
    }
    
    func setupSignInButton(){
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signInButton.backgroundColor = .clear
        signInButton.layer.borderWidth = 1.0
        signInButton.layer.borderColor = UIColor.systemBlue.cgColor
        signInButton.layer.cornerRadius = 8
        signInButton.clipsToBounds = true
        //        let attributedText = NSMutableAttributedString(string: "Already have an account? ", attributes:
        //                                                                [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
        //                                                                 NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)])
        //
        //        let attributedSubText = NSMutableAttributedString(string: "Sign in", attributes:
        //                                                                [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),
        //                                                                 NSAttributedString.Key.foregroundColor : UIColor.black
        //                                                                ])
        //        attributedText.append(attributedSubText)
        //
        //        signInButton.setAttributedTitle(attributedText, for: UIControl.State.normal)
    }
    //Dismiss keyboard when user touch view
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func validateFields(){
        guard let selectedImage = self.image else {
            let alert = UIAlertController(title: "Empty Image", message: ERROR_EMPTY_PHOTO, preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
   // ProgressHUD.showError(ERROR_EMPTY_USERNAME)
    
    return
        }
        guard let username = self.nameTextField.text, !username.isEmpty else {
            // create the alert
                    let alert = UIAlertController(title: "Empty name", message: ERROR_EMPTY_USERNAME, preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
           // ProgressHUD.showError(ERROR_EMPTY_USERNAME)
            
            return
        }
        
        guard let email = self.emailTextField.text, !email.isEmpty else {
            // create the alert
                    let alert = UIAlertController(title: "Empty e-mail", message: ERROR_EMPTY_EMAIL, preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
            //ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            return
        }
        
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            // create the alert
            let alert = UIAlertController(title: "Empty password", message: ERROR_EMPTY_PASSWORD, preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
           // ProgressHUD.showError(ERROR_EMPTY_PASSWORD)
            return
        }
        
    }
    
    func signUp(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        //ProgressHUD.show("Loading...")
        Api.User.signUp(withUsername: self.nameTextField.text!, email: self.emailTextField.text!, password: self.passwordTextField.text!, image: self.image, onSuccess: {
            //ProgressHUD.dismiss()
            onSuccess()
        }) {(errorMessage) in
            
            onError(errorMessage)
            
        }
        
    }
}

//MARK: - Avatar extension
extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
