//
//  DetailVC.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/21/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

//////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      TO DO LIST:
//1.If you navigate from detailVC to secondVC then hit the home tabbarbutton you go back to detailVC instead of firstVC
//////////////////////////////////////////////////////////////////////////////////////////////////////

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage


class DetailVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commentsTextField: UITextField!
    @IBOutlet weak var likesNumberLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var commentsTableView: UITableView!
    var likePressCount : Int?
    var currentImage:UIImage?
    var currentPhoto : Photo?
    var keyboardHeight: CGRect!
    var photoIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLikes()
        loadCommentsFromDatabase()
        
       
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.red
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.red]
        self.navigationItem.title = "Photo Detail"
        
        self.picture.image = currentImage
        
        self.commentsTableView.delegate = self
        self.commentsTableView.dataSource = self
        
        self.keyboardHeight = self.view.frame
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dissmissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func keyboardWillShow(notification:NSNotification)
    {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue{
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: keyboardHeight.height - keyboardSize.height - 1)
            
        }
    }
    
    func keyboardWillHide(notification:NSNotification)
    {
        if((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil{
            self.view.frame = keyboardHeight
        }
    }
    
    func dissmissKeyboard()
    {
        self.view.endEditing(true)
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
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete Photo", style: .default, handler: {
            (alert:UIAlertAction!) -> Void in
            print("Photo Deleted")
            //delete photo from storage
            let postsRef = Storage.storage().reference().child("posts")
            let photoRef = postsRef.child((self.currentPhoto?.storageID)!)
            photoRef.delete{error in
                if let error = error{
                    //error occured
                    ProgressHUD.showError(error.localizedDescription)
                    return
                }else{
                    //file deleted succssesfully
                    ProgressHUD.showSuccess("The Photo was Deleted")
                    //delete from database
                    let databaseRef = Database.database().reference().child("posts").child((self.currentPhoto?.uniqueID)!)
                    databaseRef.removeValue()
                    //return to firstVC 
                    let firstVC = self.navigationController?.viewControllers[0] as! FirstViewController
                    firstVC.pictures.remove(at: self.photoIndex)
                    self.goBack()
                }
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert:UIAlertAction!) -> Void in
            print("Canceled")
        })
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
        optionMenu.view.tintColor = .red

    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messageTableVC = storyboard.instantiateViewController(withIdentifier: "MessageTableVC") as! MessageTableVC
        self.navigationController?.pushViewController(messageTableVC, animated: true)
        
        messageTableVC.currentMessages = self.currentPhoto
    }
    @IBAction func commentTxtFieldTriggered(_ sender: Any) {
        saveCommentToDatabase()
        self.commentsTableView.reloadData()
    }
    
    func saveLikesToDatabase()
    {
        //get the path and run a transaction block
    
        Database.database().reference().child("posts").child((currentPhoto?.uniqueID)!).runTransactionBlock({(currentData:MutableData) -> TransactionResult in
            //gets current user and teh data as a dictionary of string any object
            if var post = currentData.value as? [String:AnyObject], let uid = Auth.auth().currentUser?.uid{
                //makes a dictionary of photos and then sees if there is any data in that dictionary if there is none then it makes an empty dictionary
                var photos: Dictionary<String, Bool>
                photos = post["photos"] as? [String:Bool] ?? [:]
                //gets the dictionary of likesCount which is an int if there is none set default value to 0
                var likesCount = post["likesCount"] as? Int ?? 0
                //checks the value of the dictionary photos against the usersid if the userid has been used remove from the dictionary else add to dictionary
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
    
    func saveCommentToDatabase()
    {
        //gets the path to comments
        let key = Database.database().reference().child("posts").child((currentPhoto?.uniqueID)!).child("comments")
        //puts the text into the comments array in the photo class
        currentPhoto?.comments.append(self.commentsTextField.text!)
        //gets the size of the array and turns it to a string to be used as a key for key value pair
        let k = String(describing: currentPhoto!.comments.count-1)
        key.updateChildValues([k:self.commentsTextField.text!])
        
    }
    
    func loadLikes()
    {
        Database.database().reference().child("posts").child((currentPhoto?.uniqueID)!).observeSingleEvent(of: .value, with: {(snapshot:DataSnapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                print(dictionary)
                let likesCount = dictionary["likesCount"] as? Int ?? 0
                print(likesCount)
                //connect likePressCount to likesCount
                self.likePressCount = likesCount
            }
        })
    }
    
    func loadCommentsFromDatabase()
    {
        Database.database().reference().child("posts").child((currentPhoto?.uniqueID)!).observeSingleEvent(of: .value, with: {(snapshot:DataSnapshot) in
            if let dictionary = snapshot.value as? [String:Any]{
                if let comments = dictionary["comments"] as? [String]{
                    self.currentPhoto?.comments = comments
                    print(comments)
                     self.commentsTableView.reloadData()
                    
                }
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentPhoto!.comments.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = commentsTableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        
        cell.comment.text = currentPhoto?.comments[indexPath.row]
        
        return cell
    }
}
