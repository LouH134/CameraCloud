//
//  DetailVC.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/21/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import FirebaseDatabase

class DetailVC: UIViewController {
    
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var likesNumberLabel: UILabel!
    var likePressCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
        self.navigationItem.title = "Photo Detail"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goBack()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func likesButtonPressed(_ sender: Any) {
        self.likePressCount = Int(likesNumberLabel.text!)!
        self.likesNumberLabel.text = String(likePressCount + 1)
        
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
    }
    

}
