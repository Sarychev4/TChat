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
import AVFoundation

class StorageService {
    //MARK: - PUSH AUDIO TO FIREBASE
    static func saveAudioMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        let ref = Ref().storageSpecificAudioMessage(id: id)
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil{
                //print("Error!")
                onError(error!.localizedDescription)
            }
    
            ref.downloadURL ( completion: { (downloadUrl, error) in
                if let audioUrl = downloadUrl?.absoluteString {
                    //print(audioUrl)
                    let dict: Dictionary<String, Any> = [
                        "audioUrl": audioUrl as Any,
                        "text": "" as Any
                    ]
                    onSuccess(dict)
                }
            })
        }

    }
    //MARK: - PUSH VIDEO TO FIREBASE
    static func saveVideoMessage(url: URL, id: String, onSuccess: @escaping(_ value: Any) -> Void, onError: @escaping(_ errorMessage: String) -> Void){
        let ref = Ref().storageSpecificVideoMessage(id: id)
        ref.putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil{
                onError(error!.localizedDescription)
            }
            
            ref.downloadURL(completion: { (downloadUrl, error) in
                if let thumbnailImage = self.thumbnailImageForFileUrl(url){
                    StorageService.savePhotoMessage(image: thumbnailImage, id: id, onSuccess: { (value) in
                        if let dict = value as? Dictionary<String, Any> {
                            var dictValue = dict
                            
                            if let videoUrl = downloadUrl?.absoluteString {
                                dictValue["videoUrl"] = videoUrl
                                
                            }
                            onSuccess(dictValue)
                        }
                    }, onError: { (errorMessage) in
                        onError(errorMessage)
                    })
                }
            })
        }
    }
    
    
    static func thumbnailImageForFileUrl(_ url: URL) -> UIImage? {
        let asset = AVAsset(url: url) //ADD PARAMETER
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        var time = asset.duration
        time.value = min(time.value, 2)
        do {
            let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError {
            print(error.localizedDescription)
            return nil
        }
    }
    
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
