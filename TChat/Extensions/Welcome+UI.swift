//
//  ViewController+UI.swift
//  TChat
//
//  Created by Артем Сарычев on 26.04.21.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import ProgressHUD
import Firebase

extension Welcome {
    
    func setupSignUpButton(){
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signUpButton.backgroundColor = UIColor(hexString: "0584FE")
        signUpButton.layer.cornerRadius = 8
        signUpButton.clipsToBounds = true
    }
    
    func setupSignInButton(){
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signInButton.backgroundColor = .clear
        signInButton.layer.borderWidth = 1.0
        signInButton.layer.borderColor = UIColor(hexString: "0584FE").cgColor
        signInButton.layer.cornerRadius = 8
        signInButton.clipsToBounds = true
    }
}
