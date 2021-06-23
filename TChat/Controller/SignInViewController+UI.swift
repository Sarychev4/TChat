//
//  SignInViewController+UI.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import UIKit
import ProgressHUD

extension SignInViewController {
    
    func setupTitleLabel(){
        
        let title = "Sign In"
        
//        let attributedText = NSMutableAttributedString(string: title, attributes:
//                                                        [NSAttributedString.Key.font : UIFont.init(name: "Didot", size: 28)!,
//                                                         NSAttributedString.Key.foregroundColor : UIColor.black])
//        
//        titleTextLabel.attributedText = attributedText
        
    }
    
    func setupEmailTextField(){
        
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        emailContainerView.layer.cornerRadius = 8
        emailContainerView.clipsToBounds = true
        emailContainerView.backgroundColor = UIColor(hexString: "F5F5F5")
        
        emailTextField.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
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
        
        let placeholderAttr = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        passwordTextField.attributedPlaceholder = placeholderAttr
        passwordTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
        
    }
    
    func setupSignInButton(){
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signInButton.backgroundColor = .systemBlue
        signInButton.layer.cornerRadius = 8
        signInButton.clipsToBounds = true
        signInButton.setTitleColor(.white, for: UIControl.State.normal)
    }
    
    func setupForgotPasswordButton(){
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        forgotPasswordButton.backgroundColor = .clear
        forgotPasswordButton.layer.borderWidth = 1.0
        forgotPasswordButton.layer.borderColor = UIColor.systemBlue.cgColor
        forgotPasswordButton.layer.cornerRadius = 8
        forgotPasswordButton.clipsToBounds = true
        forgotPasswordButton.setTitleColor(.systemBlue, for: UIControl.State.normal)
    }
    
    func setupSignUpButton(){
//        let attributedText = NSMutableAttributedString(string: "Don't have an account? ", attributes:
//                                                                [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16),
//                                                                 NSAttributedString.Key.foregroundColor : UIColor(white: 0, alpha: 0.65)])
//        
//        let attributedSubText = NSMutableAttributedString(string: "Sign up", attributes:
//                                                                [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 18),
//                                                                 NSAttributedString.Key.foregroundColor : UIColor.black
//                                                                ])
//        attributedText.append(attributedSubText)
//        
//        signUpButton.setAttributedTitle(attributedText, for: UIControl.State.normal)
        
    }
    
    func validateFields(){
        
        guard let email = self.emailTextField.text, !email.isEmpty else {
            //ProgressHUD.showError(ERROR_EMPTY_EMAIL)
            let alert = UIAlertController(title: "Empty e-mail", message: ERROR_EMPTY_EMAIL, preferredStyle: UIAlertController.Style.alert)

            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

            // show the alert
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "Empty password", message: ERROR_EMPTY_PASSWORD, preferredStyle: UIAlertController.Style.alert)

                    // add an action (button)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                    // show the alert
                    self.present(alert, animated: true, completion: nil)
            //ProgressHUD.showError(ERROR_EMPTY_PASSWORD)
            return
        }
    }
    
    func signIn(onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        ProgressHUD.show("Loading...")
        Api.User.signIn(email: self.emailTextField.text!, password: self.passwordTextField.text!, onSuccess: {
            ProgressHUD.dismiss()
            onSuccess()
        }) { (errorMessage) in
            onError(errorMessage)
        }
    }
    
}
