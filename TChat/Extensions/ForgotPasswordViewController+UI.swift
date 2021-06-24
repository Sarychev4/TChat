//
//  ForgotPasswordViewController+UI.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import UIKit

extension ForgotPasswordViewController {
    
    func setupEmailTextField(){
        emailContainerView.layer.borderWidth = 1
        emailContainerView.layer.borderColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1).cgColor
        emailContainerView.layer.cornerRadius = 3
        emailContainerView.clipsToBounds = true
        emailContainerView.backgroundColor = UIColor(hexString: "F5F5F5")
        
        emailTextField.borderStyle = .none
        
        let placeholderAttr = NSAttributedString(string: "Email Address", attributes: [NSAttributedString.Key.foregroundColor : UIColor(red: 170/255, green: 170/255, blue: 170/255, alpha: 1)])
        
        emailTextField.attributedPlaceholder = placeholderAttr
        emailTextField.textColor = UIColor(red: 99/255, green: 99/255, blue: 99/255, alpha: 1)
    }
    
    func setupResetButton(){
        resetButton.setTitle("Reset my password", for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        resetButton.backgroundColor = .systemBlue
        resetButton.layer.cornerRadius = 8
        resetButton.clipsToBounds = true
        resetButton.setTitleColor(.white, for: UIControl.State.normal)
    }
    
    func setupBackToSignInButton(){
        backToSignInButton.setTitle("Back to sign in", for: .normal)
        backToSignInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backToSignInButton.backgroundColor = .clear
        backToSignInButton.layer.borderWidth = 1.0
        backToSignInButton.layer.borderColor = UIColor.systemBlue.cgColor
        backToSignInButton.layer.cornerRadius = 8
        backToSignInButton.clipsToBounds = true
        backToSignInButton.setTitleColor(.systemBlue, for: UIControl.State.normal)
    }
}
