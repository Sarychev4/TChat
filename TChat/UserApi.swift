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
    
    func signIn(email: String, password: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { (authData, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            print(authData?.user.uid)
            onSuccess()
        }
    }
    
    func signUp(withUsername username: String, email: String, password: String, image: UIImage?, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        
        Auth.auth().createUser(withEmail: email, password: password) { (authDataResult, error) in
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            if let authData = authDataResult {
                
                let dict: Dictionary<String, Any> = [
                    UID: authData.user.uid,
                    EMAIL: authData.user.email ?? "Empty",
                    USERNAME: username,
                    PROFILE_IMAGE_URL: "",
                    STATUS: "Default status"
                ]
                
                guard let imageSelected = image else {
                    ProgressHUD.showError(ERROR_EMPTY_PHOTO)
                    return
                }
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
    
    func observeUsers(onSuccess: @escaping(UserCompletion)){
        //        print(Ref().databaseRoot.ref.description())
        //        print(Ref().databaseUsers.ref.description())
        Ref().databaseUsers.observe(.childAdded) { (snaphot) in
            //           print(snaphot.value)
            if let dict = snaphot.value as? Dictionary<String, Any> {
                //                let email = dict["email"] as! String
                //                let username = dict["username"] as! String
                //                print(email)
                //                print(username)
                if let user = User.transformUser(dict: dict){
                    onSuccess(user)
                   // self.users.append(user)
                }
               // self.tableView.reloadData() //reloads rows and sections
            }
        }
    }
    
}

typealias UserCompletion = (User) -> Void //used in observeUsers
