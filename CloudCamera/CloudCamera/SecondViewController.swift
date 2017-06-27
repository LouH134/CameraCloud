//
//  SecondViewController.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/12/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

protocol ImageUploadDelegate {
    func didUploadNewPhoto(_ photo: Photo)
}

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadPicButton: UIButton!
    @IBOutlet weak var uploadPicTextButton: UIButton!
    @IBOutlet weak var cameraPic: UIButton!
    @IBOutlet weak var textCameraButton: UIButton!
    var selectedImage:UIImage?
    var delegate: ImageUploadDelegate?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func takePhoto(_ sender: UIButton) {
        if sender == self.cameraPic{
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            
            present(picker, animated: true, completion: nil)
        }else if sender == self.textCameraButton{
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            picker.modalPresentationStyle = .fullScreen
            
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func uploadPicture(_ sender: UIButton) {
        if sender == self.uploadPicButton{
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.allowsEditing = false
            picker.navigationBar.isTranslucent = false
            picker.navigationBar.barTintColor = .black
            picker.navigationBar.tintColor = .red
            picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
            
            picker.sourceType = .photoLibrary
            
            present(picker, animated: true, completion: nil)
        }else if sender == self.uploadPicTextButton{
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.allowsEditing = false
            
            picker.navigationBar.isTranslucent = false
            picker.navigationBar.barTintColor = .black
            picker.navigationBar.tintColor = .red
            picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
            
            picker.sourceType = .photoLibrary
            
            present(picker, animated: true, completion: nil)
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
        }catch let logOutError{
            print(logOutError)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let chosenImage = info["UIImagePickerControllerOriginalImage"] as? UIImage
        {
            self.selectedImage = chosenImage
        }
        ProgressHUD.show("Waiting....", interaction: false)
        //lets the image be saved as data
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1){
            let photoID = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference(forURL: Config.ROOT_URL).child("posts").child(photoID)
            storageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                if error != nil{
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                
                //takes the metadata and makes a urlstring that can be saved in firebase
                let photoURL = metadata?.downloadURL()?.absoluteString
                //let chosenPhoto = Photo(image: self.selectedImage!, photoUrlString: photoURL!)
                
                self.sendDataToDatabase(photoURL: photoURL!)
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func sendDataToDatabase(photoURL: String)
    {
        //create node in the database
        let ref = Database.database().reference()
        let postsReference = ref.child("posts")
        let newPostID = postsReference.childByAutoId().key
        let newPostReference = postsReference.child(newPostID)
        //saving username and email to database
        newPostReference.setValue(["photoURL":photoURL], withCompletionBlock: {(error, ref) in
            if error != nil{
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            ProgressHUD.showSuccess("Woot!, it worked!")
            self.delegate?.didUploadNewPhoto(Photo(photoUrlString: photoURL))
        })

    }


}

