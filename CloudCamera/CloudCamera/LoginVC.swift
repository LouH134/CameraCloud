//
//  LoginVC.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/15/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginVC: UIViewController {

 
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.isEnabled = false
        
        handleTextField()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if Auth.auth().currentUser != nil{
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {(timer) in
                self.performSegue(withIdentifier: "goToTabBarVC", sender: nil)
            })
        }
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
        email.addTarget(self, action: #selector(SignUpVC.textFieldChanged), for: UIControlEvents.editingChanged)
        password.addTarget(self, action: #selector(SignUpVC.textFieldChanged), for: UIControlEvents.editingChanged)
    }
    
    func textFieldChanged()
    {
        guard let emailString = email.text, !emailString.isEmpty, let passwordString = password.text, !passwordString.isEmpty else {
            self.loginButton.setTitleColor(UIColor.red, for: UIControlState.normal)
            self.loginButton.isEnabled = false
            
            return
        }
        self.loginButton.setTitleColor(UIColor.purple, for: UIControlState.normal)
        self.loginButton.isEnabled = true
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        ProgressHUD.show("Waiting....", interaction: false)
        AuthService.logIn(email: self.email.text!, password: self.password.text!, onSuccess: {
            ProgressHUD.showSuccess("Success")
            self.performSegue(withIdentifier: "goToTabBarVC", sender: nil)
        }, onError: { error in
            ProgressHUD.showError(error)
        })
        self.view.endEditing(true)
        
    }
}
