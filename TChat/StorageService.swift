//
//  StorageService.swift
//  TChat
//
//  Created by Артем Сарычев on 27.04.21.
//

import Foundation
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import ProgressHUD

class StorageService {
    
    //MARK: - PUSH PHOTO TO FIREBASE
    static func savePhotoMessage(image: UIImage?, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        if let imagePhoto = image {
            let ref = Ref().storageSpecificImageMessage(id: id)
            if let data = imagePhoto.jpegData(compressionQuality: 0.5){
                
                ref.putData(data, metadata: nil) { (metadata, error) in
                    if error != nil{
                        onError(error!.localizedDescription)
                    }
                    ref.downloadURL(completion: {(url, error) in
                        if let metaImageUrl = url?.absoluteString {
                            let dict: Dictionary<String, Any> = [
                                "imageUrl": metaImageUrl as Any,
                                "height": imagePhoto.size.height as Any,
                                "width": imagePhoto.size.width as Any,
                                "text": "" as Any
                            ]
                            onSuccess(dict)
                        }
                    })
                    
                }
            }
        }
    }
    static func savePhoto(username: String, uid: String, data: Data, metadata: StorageMetadata, storageProfileRef: StorageReference, dict: Dictionary<String, Any>,
                          onSuccess: @escaping() -> Void, onError: @escaping(_ errorMessage: String) -> Void) {
                            

        
        //Put Data in storage
        storageProfileRef.putData(data, metadata: metadata) { (storageMetaData, error) in
            if error != nil {
                onError(error!.localizedDescription)
                return
            }
            
            //Download image to upload in FireBase Database
            storageProfileRef.downloadURL(completion: { (url, error) in
                if let metaImageUrl = url?.absoluteString { //Convert to String
                    
                    if let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()//Creates an object which may be used to change the user's profile data.
                    {
                        changeRequest.photoURL = url
                        changeRequest.displayName = username
                        changeRequest.commitChanges(completion: {(error) in
                            if let error = error{
                                ProgressHUD.showError(error.localizedDescription)
                            }
                        })
                    }
                    
                    var dictTemp = dict
                    dictTemp[PROFILE_IMAGE_URL] = metaImageUrl
                    
                    
                    Ref().databaseSpecificUser(uid: uid).updateChildValues(dictTemp, withCompletionBlock: { (error, ref) in
                            if error == nil {
                                onSuccess()
                            } else {
                                onError(error!.localizedDescription)
                            }
                        })
                    
                }
            })
        }
    }
}
