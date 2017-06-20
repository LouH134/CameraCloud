//
//  AuthService.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/19/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AuthService{
    
    
    static func logIn(email:String, password:String, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage:String?) -> Void)
    {
        print("login")
        Auth.auth().signIn(withEmail: email, password: password, completion: {(user, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            onSuccess()
        })
    }
    
    static func signUp(username: String, email:String, password:String, imageData: Data, onSuccess: @escaping () -> Void, onError: @escaping (_ errorMessage:String?) -> Void)
    {
        Auth.auth().createUser(withEmail: email, password: password, completion: {(user, error) in
            if error != nil{
                onError(error!.localizedDescription)
                return
            }
            
            //get unique id for each user
            let uid = user?.uid
            //store photo in cloud
            let storageRef = Storage.storage().reference(forURL: Config.ROOT_URL).child("profile_image").child(uid!)
           
                storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                    if error != nil{
                        return
                    }
                    
                    //takes the metadata and makes a urlstring that can be saved in firebase
                    let profileImageURL = metadata?.downloadURL()?.absoluteString
                    
                   self.setUserInfo(profileImageUrl: profileImageURL!, username: username, email: email, uid: uid!, onSuccess: onSuccess)
                    
            })
        })
    }
    
    static func setUserInfo(profileImageUrl: String, username: String, email: String, uid: String, onSuccess: @escaping () -> Void)
    {
        //create node in the database
        let ref = Database.database().reference()
        let userReference = ref.child("users")
        
        let newUserReference = userReference.child(uid)
        //saving username and email to database
        newUserReference.setValue(["username": username, "email": email, "profileImageURL": profileImageUrl])
        
        onSuccess()
    }

}
