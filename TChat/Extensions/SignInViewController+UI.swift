//
//  SignInViewController+UI.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import UIKit
import ProgressHUD

extension SignInViewController {
    
    //Dismiss keyboard when user touch view
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
        emailTextField.textColor = UIColor(hexString: "000000")
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
        passwordTextField.textColor = UIColor(hexString: "000000")
        
    }
    
    func setupSignInButton(){
        
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signInButton.backgroundColor = UIColor(hexString: "0584FE")
        signInButton.layer.cornerRadius = 8
        signInButton.clipsToBounds = true
        signInButton.setTitleColor(.white, for: UIControl.State.normal)
    }
    
    func setupForgotPasswordButton(){
        forgotPasswordButton.setTitle("Forgot Password?", for: .normal)
        forgotPasswordButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        forgotPasswordButton.backgroundColor = .clear
        forgotPasswordButton.layer.borderWidth = 1.0
        forgotPasswordButton.layer.borderColor = UIColor(hexString: "0584FE").cgColor
        forgotPasswordButton.layer.cornerRadius = 8
        forgotPasswordButton.clipsToBounds = true
        forgotPasswordButton.setTitleColor(UIColor(hexString: "0584FE"), for: UIControl.State.normal)
    }
    
    func validateFields(){
        
        guard let email = self.emailTextField.text, !email.isEmpty else {
            let alert = UIAlertController(title: "Empty e-mail", message: ERROR_EMPTY_EMAIL, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        guard let password = self.passwordTextField.text, !password.isEmpty else {
            let alert = UIAlertController(title: "Empty password", message: ERROR_EMPTY_PASSWORD, preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
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
            ProgressHUD.dismiss()
        }
    }
    
}
