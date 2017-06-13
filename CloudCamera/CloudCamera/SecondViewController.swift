//
//  SecondViewController.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/12/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadPicButton: UIButton!
    @IBOutlet weak var uploadPicTextButton: UIButton!
    @IBOutlet weak var cameraPic: UIButton!
    @IBOutlet weak var textCameraButton: UIButton!
    
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
            picker.sourceType = .photoLibrary
            
            present(picker, animated: true, completion: nil)
        }else if sender == self.uploadPicTextButton{
            let picker = UIImagePickerController()
            picker.delegate = self
            
            picker.allowsEditing = false
            picker.sourceType = .photoLibrary
            
            present(picker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        guard let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
//            else{
//                return
//        }
//        
        
        dismiss(animated: true, completion: nil)
        
    }


}

