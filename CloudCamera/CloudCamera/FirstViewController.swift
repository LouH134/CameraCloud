//
//  FirstViewController.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/12/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class FirstViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{

    @IBOutlet weak var collectionView: UICollectionView!
    var pictures = [Photo]()
    var screenSize:CGRect!
    var screenWidth:CGFloat!
    var screenHeight:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        //I know the second VC of the tab bar is my SecondViewController, so.. I assign my SecondViewControllers delegate, to this class(FirstViewController)
        if let uploadVC = self.tabBarController?.viewControllers?[1] as? SecondViewController {
            uploadVC.delegate = self
        }
        
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
        self.navigationItem.title = "Moments"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "LogOut", style: .plain, target: self, action: #selector(logOut))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        
        self.screenSize = UIScreen.main.bounds
        self.screenWidth = screenSize.width
        self.screenHeight = screenSize.height
        
        //moves the cells in the collection closer together
        let layout:UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: screenWidth/3 , height: screenHeight/3)
        collectionView.collectionViewLayout = layout
        
        loadPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.collectionView.reloadData()
    }
    
    func loadPosts()
    {
        //get the root reference from database get posts folder childadded looks at all exsiting in posts and gets it by snapshot
        Database.database().reference().child("posts").observeSingleEvent(of: .value) {(snapshot:DataSnapshot) in
            //turn data into a String:Any dictionary get the folder get the urlstring as post put it into an array
            if let dictionary = snapshot.value as? [String:Any]{
                
                for (key, value) in dictionary {
                    guard let value = value as? [String: Any] else{
                        return
                    }
                    guard let photoUrl =  value["photoURL"] as? String else{
                        return
                    }
                    guard let storageIdString = value["storageID"] as? String else{
                        return
                    }
                    
                    let post = Photo(photoUrlString: photoUrl, uniqueID: key, storageID:storageIdString)
                    
                     self.pictures.append(post)
                }
                
                self.collectionView.reloadData()
                // main thread call another method
                self.loadPhoto()
            }
        }
    }
    
    func loadPhoto()
    {
        for imageObject in pictures {
              let myUrl = URL(string: imageObject.photoURL)
            
            URLSession.shared.dataTask(with: myUrl!){(data, _,_) in
                guard let imageData = data
                    else {return}
                
                guard let image = UIImage(data: imageData)
                    else {return}
                
                DispatchQueue.main.async {
                    imageObject.photoImage = image
                    self.collectionView.reloadData()
                }
            }.resume()
        }
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
        return self.pictures.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCollectionViewCell
        cell.imageView.image = self.pictures[indexPath.row].photoImage
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        self.navigationController?.pushViewController(detailVC, animated: true)
        detailVC.currentPhoto = self.pictures[indexPath.row]
        detailVC.currentImage = self.pictures[indexPath.row].photoImage
        detailVC.photoIndex = indexPath.row
    }
    
    


}

extension FirstViewController: ImageUploadDelegate {
    func didUploadNewPhoto(_ photo: Photo) {
        pictures.append(photo)
        collectionView.reloadData()
        loadPhoto()
    }
}

