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
        emailTextField.textColor = UIColor(hexString: "000000")
    }
    
    //Dismiss keyboard when user touch view
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setupResetButton(){
        resetButton.setTitle("Reset my password", for: .normal)
        resetButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        resetButton.backgroundColor = UIColor(hexString: "0584FE")
        resetButton.layer.cornerRadius = 8
        resetButton.clipsToBounds = true
        resetButton.setTitleColor(.white, for: UIControl.State.normal)
    }
    
    func setupBackToSignInButton(){
        backToSignInButton.setTitle("Back to sign in", for: .normal)
        backToSignInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        backToSignInButton.backgroundColor = .clear
        backToSignInButton.layer.borderWidth = 1.0
        backToSignInButton.layer.borderColor = UIColor(hexString: "0584FE").cgColor
        backToSignInButton.layer.cornerRadius = 8
        backToSignInButton.clipsToBounds = true
        backToSignInButton.setTitleColor(UIColor(hexString: "0584FE"), for: UIControl.State.normal)
    }
}
