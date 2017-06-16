//
//  SignUpVC.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/15/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    var selectedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        self.profileImage.addGestureRecognizer(tapGesture)
        self.profileImage.isUserInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectProfileImage()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.barTintColor = .black
        picker.navigationBar.tintColor = .red
        picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
        present(picker, animated: true, completion: nil)
        
    }

    @IBAction func signupButtonPressed(_ sender: Any) {
        Auth.auth().createUser(withEmail: self.email.text!, password: self.password.text!, completion: {(user, error) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            
            //get unique id for each user
            let uid = user?.uid
            //store photo in cloud
            let storageRef = Storage.storage().reference(forURL:"gs://cameracloud-5d590.appspot.com").child("profile_image").child(uid!)
            if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1){
                storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                    if error != nil{
                        return
                    }
                    let profileImageURL = metadata?.downloadURL()?.absoluteString
                    //create node in the database
                    let ref = Database.database().reference()
                    let userReference = ref.child("users")
                    
                    let newUserReference = userReference.child(uid!)
                    //saving username and email to database
                    newUserReference.setValue(["username":self.username.text!, "email":self.email.text!, "profileImageURL":profileImageURL])
                    
                })
            }
        })
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            self.selectedImage = image
            self.profileImage.image = image
        }
        
        dismiss(animated: true, completion: nil)
    }

    
    @IBAction func dismissSignup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
