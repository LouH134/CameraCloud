//
//  DetailVC.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/21/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class DetailVC: UIViewController {
    
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    var likePressCount : Int?
    var currentImage:UIImage?
    var currentKey:String!
    var currentUrlString:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLikes()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
        self.navigationItem.title = "Photo Detail"
        
        self.picture.image = currentImage
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
        if self.likePressCount == 0{
            self.likePressCount!+=1
            self.likesNumberLabel.text = String(likePressCount!)
        }else{
            self.likePressCount!-=1
            self.likesNumberLabel.text = String(likePressCount!)
        }
        
        
        saveLikesToDatabase()
        
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
    }
    
    func saveLikesToDatabase()
    {
        let currentPhoto = Photo(photoUrlString: self.currentUrlString, uniqueID: self.currentKey)
        //get uniqueID to specific photo
        Database.database().reference().child("posts").child(currentPhoto.uniqueID).runTransactionBlock({(currentData:MutableData) -> TransactionResult in
            if var post = currentData.value as? [String:AnyObject], let uid = Auth.auth().currentUser?.uid{
                var photos: Dictionary<String, Bool>
                photos = post["photos"] as? [String:Bool] ?? [:]
                var likesCount = post["likesCount"] as? Int ?? 0
                if let _ = photos[uid]{
                    likesCount -= 1
                    photos.removeValue(forKey: uid)
                }else{
                    likesCount += 1
                    photos[uid] = true
                }
                post["likesCount"] = likesCount as AnyObject?
                post["photos"] = photos as AnyObject?
                
                currentData.value = post
                
                return TransactionResult.success(withValue: currentData)
            }
            return TransactionResult.success(withValue: currentData)
        }){(error, commited, snapshot) in
            if let error = error{
                print(error.localizedDescription)
            }
        }
    }
    
    func loadLikes()
    {
        let currentPhoto = Photo(photoUrlString: self.currentUrlString, uniqueID: self.currentKey)
        Database.database().reference().child("posts").child(currentPhoto.uniqueID).observeSingleEvent(of: .value, with: {(snapshot:DataSnapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                print(dictionary)
                let likesCount = dictionary["likesCount"] as? Int ?? 0
                print(likesCount)
                //connect likePressCount to likesCount
                self.likePressCount = likesCount
            }
        })
    }
    
    /////////////////////////////////////////////////////////////////////////
    //minor things to fix: 1.If you navigate from detailVC to secondVC then//
    //hit the home tabbarbutton you go back to detailVC instead of firstVC //
    ////////////////////////////////////////////////////////////////////////
    
}
