//
//  FirstViewController.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/12/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import FirebaseAuth

class FirstViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource
{

    @IBOutlet weak var collectionView: UICollectionView!
    var pictures = [UIImage]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
        self.navigationItem.title = "Moments"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(logOut))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        
    }
    
    func logOut()
    {
        do{
            try Auth.auth().signOut()
        }catch let logOutError{
            print(logOutError)
        }
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.pictures.count
        return 35
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = #imageLiteral(resourceName: "camera")
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    


}

