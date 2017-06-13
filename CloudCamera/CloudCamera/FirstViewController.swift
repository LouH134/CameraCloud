//
//  FirstViewController.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/12/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

