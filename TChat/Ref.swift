//
//  Ref.swift
//  TChat
//
//  Created by Артем Сарычев on 28.04.21.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

let REF_USER = "users"
let URL_STORAGE_ROOT = "gs://tchat-8865f.appspot.com"
let STORAGE_PROFILE = "profile"
let PROFILE_IMAGE_URL = "profileImageUrl"
let UID = "uid"
let EMAIL = "email"
let USERNAME = "username"
let STATUS = "status"
let ERROR_EMPTY_PHOTO = "Please choose your profile image"
let ERROR_EMPTY_EMAIL = "Please enter an email address"
let ERROR_EMPTY_USERNAME = "Please enter an username"
let ERROR_EMPTY_PASSWORD = "Please enter a password"
let ERROR_EMPTY_EMAIL_RESET = "Please enter an email address for password reset"
let SUCCES_EMAIL_RESET = "We  have just sent you a password reset email. Please check your inbox and follow the instuctions"

let IDENTIFIER_TABBAR = "TabBarVC"
let IDENTIFIER_WELCOME = "WelcomeVC"

let IDENTIFIER_CELL_USERS = "UserTableViewCell"

class Ref {
    let databaseRoot: DatabaseReference = Database.database().reference()
    
    var databaseUsers: DatabaseReference {
        return databaseRoot.child("users")
    }
    
    func databaseSpecificUser(uid: String) -> DatabaseReference {
        return databaseUsers.child(uid)
    }
    
    // Storage Ref
    let storageRoot = Storage.storage().reference(forURL: URL_STORAGE_ROOT)
    
    var storageProfile: StorageReference {
        return storageRoot.child(STORAGE_PROFILE)
    }
    
    func storageSpecificProfile(uid: String) -> StorageReference{
        return storageProfile.child(uid)
    }
}
