//
//  UserApi.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import Foundation
import FirebaseAuth
import Firebase
import ProgressHUD
import FirebaseStorage
import FirebaseDatabase

class UserApi {
    
    var users: Set<User> = []
    
    var currentUserId: String {

        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.uid : ""
    }
    
    var currentUserName: String {
        
        return Auth.auth().currentUser != nil ? Auth.auth().currentUser!.displayName! : ""
    }
    
    
    func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    func signUp(withUsername username: String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        
        guard let imageSelected = image else {
           
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            if let authData = authDataResult {
                
                let dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,
                    EMAIL: authData.user.email ?? "Empty",
                    USERNAME: username,
                    PROFILE_IMAGE_URL: "",
                    TITLE: "New User"
                ]
                
               
                //Convert data
                guard let imageData = imageSelected.jpegData(compressionQuality: 0.4) else {
                    return
                }
                
                let storageProfile = Ref().storageSpecificProfile(uid: authData.user.uid)
                
                //Put Data in storage
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpg"
                
                StorageService.savePhoto(username: username, uid: authData.user.uid, data: imageData, metadata: metadata, storageProfileRef: storageProfile, dict: dict, onSuccess: {
                    onSuccess() //signUp parameter
                }, onError: { (errorMessage) in
                    onError(errorMessage)
                })
            }
        }
    }
    
    func saveUserProfile(dict: Dictionary<String, Any>, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Ref().databaseSpecificUser(uid: Api.User.currentUserId).updateChildValues(dict) { (error, dataRef) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        }
    }
    
    func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil{
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    func logOut(){
        do {
            Api.User.isOnline(bool: false)
            try Auth.auth().signOut()
            
            
        } catch{
            ProgressHUD.showError(error.localizedDescription)
            return
        }
        //MARK: - BACK TO REVIEW
        //(UIApplication.shared.delegate as! SceneDelegate).configureInitialViewController()
         (UIApplication.shared.connectedScenes
             .first!.delegate as! SceneDelegate).configureInitialViewController()
    }
    
    func observeUsers(onUpdate: @escaping(() -> Void)) {
        Ref().databaseUsers.observe(.value) { (snapshot) in
            guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {
                return
            }
            let userJsons: [[String: Any]] = allObjects.compactMap({ $0.value as? [String: Any] })
            for userJson in userJsons {
                if let user = User.transformUser(dict: userJson){
                        self.users.insert(user)
                }
            }
            onUpdate()
        }
    }
    
    func getUserInforSingleEvent(uid: String, onSuccess: @escaping(UserCompletion)){
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict){
                    onSuccess(user)
                }
            }
        }
    }
    
    func getUserInfor(uid: String, onSuccess: @escaping(UserCompletion)){
        let ref = Ref().databaseSpecificUser(uid: uid)
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if let dict = snapshot.value as? Dictionary<String, Any> {
                if let user = User.transformUser(dict: dict){
                    onSuccess(user)
                }
            }
        }
    }
    
    func isOnline(bool: Bool) {
        if !Api.User.currentUserId.isEmpty {
            let ref = Ref().databaseIsOnline(uid: Api.User.currentUserId)
            let dict: Dictionary<String, Any> = [
                "online": bool as Any,
                "latest": Date().timeIntervalSince1970 as Any
            ]
            ref.updateChildValues(dict)
        }
    }
    
    func recording(from: String, to: String){
        let ref = Ref().databaseIsOnline(uid: from)
        let dict: Dictionary<String, Any> = [
            "recording": to
        ]
        ref.updateChildValues(dict)
    }
    
}

typealias UserCompletion = (User) -> Void //used in observeUsers
