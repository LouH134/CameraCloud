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
    
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    
    var selectedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.signUpButton.isEnabled = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfileImage))
        self.profileImage.addGestureRecognizer(tapGesture)
        self.profileImage.isUserInteractionEnabled = true
        
        handleTextField()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func handleTextField()
    {
        username.addTarget(self, action: #selector(SignUpVC.textFieldChanged), for: UIControlEvents.editingChanged)
        email.addTarget(self, action: #selector(SignUpVC.textFieldChanged), for: UIControlEvents.editingChanged)
        password.addTarget(self, action: #selector(SignUpVC.textFieldChanged), for: UIControlEvents.editingChanged)
    }
    
    func textFieldChanged()
    {
        guard let userNameString = username.text, !userNameString.isEmpty, let emailString = email.text, !emailString.isEmpty, let passwordString = password.text, !passwordString.isEmpty else {
            self.signUpButton.setTitleColor(UIColor.red, for: UIControlState.normal)
            self.signUpButton.isEnabled = false
            
            return
        }
        self.signUpButton.setTitleColor(UIColor.purple, for: UIControlState.normal)
        self.signUpButton.isEnabled = true
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
        //lets the image be saved as data
        if let profileImg = self.selectedImage, let imageData = UIImageJPEGRepresentation(profileImg, 0.1){
            AuthService.signUp(username: self.username.text!, email: self.email.text!, password: self.password.text!, imageData: imageData, onSuccess: {
                self.performSegue(withIdentifier: "goToTabBarVC", sender: nil)
            }, onError: {(errorString) in
                print(errorString!)
                
            })
        }
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
