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
    

    //MARK: Sign In Buttons
    //Facebook
    func setupFacebookButton(){
        
        signInFacebookButton.setTitle("Sign in with Facebook", for: .normal)
        signInFacebookButton.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        signInFacebookButton.backgroundColor = UIColor(red: 58/255, green: 85/255, blue: 159/255, alpha: 1)
        signInFacebookButton.layer.cornerRadius = 5
        signInFacebookButton.clipsToBounds = true
        
        signInFacebookButton.setImage(UIImage(named: "icon-facebook"), for: .normal)
        signInFacebookButton.imageView?.contentMode = .scaleAspectFit
        signInFacebookButton.tintColor = .white
        signInFacebookButton.imageEdgeInsets = UIEdgeInsets(top: 12, left: -15, bottom: 12, right: 0)
        
        signInFacebookButton.addTarget(self, action: #selector(fbButtonDidTap), for: .touchUpInside)
    }
    
    @objc func fbButtonDidTap(){
        let fbLogimManager = LoginManager()
     //   fbLogimManager.setl
        fbLogimManager.logIn(permissions: ["public_profile", "email", "user_friends", "user_photos"], from: self) { (result, error) in
            if let error = error {
                ProgressHUD.showError(error.localizedDescription)
                return
            }
            
            guard let accessToken = AccessToken.current else {
                ProgressHUD.showError("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            Auth.auth().signIn(with: credential, completion:  { (result, error) in
                if let error = error {
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }
                
                if let authData = result {
                    print("AuthData")
                   print(authData.user.uid)
                   
//                    print(authData.user.providerData[0])
//                    print(Auth.auth().currentUser?.providerData[0].providerID)
//                    print(authData.user.photoURL!.absoluteString + "?type=large")
                    //rint(authData.user. + "?type=large")
                 //   print(authData.user.pro)
                   // print(authData.user.email)
                    
                    let dict: Dictionary<String, Any> = [
                        UID: authData.user.uid,
                        EMAIL: authData.user.email ?? "Empty",
                        USERNAME: authData.user.displayName as Any,
                        PROFILE_IMAGE_URL: (authData.user.photoURL == nil) ? "" : authData.user.photoURL!.absoluteString,
                        STATUS: "Default status"
                    ]
                 
                    Ref().databaseSpecificUser(uid: authData.user.uid).updateChildValues(dict, withCompletionBlock: { (error, ref) in
                        if error == nil {
                            Api.User.isOnline(bool: true)
                             (UIApplication.shared.connectedScenes
                                 .first!.delegate as! SceneDelegate).configureInitialViewController()
                        } else {
                            ProgressHUD.showError(error!.localizedDescription)
                        }
                    })
                    
                }
            })
        }
    }
    
    
    //Create a new account
    func setupSignUpButton(){
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signUpButton.backgroundColor = .systemBlue
        signUpButton.layer.cornerRadius = 8
        signUpButton.clipsToBounds = true
    }
    
    func setupSignInButton(){
        signInButton.setTitle("Sign In", for: .normal)
        signInButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signInButton.backgroundColor = .clear
        signInButton.layer.borderWidth = 1.0
        signInButton.layer.borderColor = UIColor.systemBlue.cgColor
        signInButton.layer.cornerRadius = 8
        signInButton.clipsToBounds = true
    }
}
