//
//  Photo.swift
//  CloudCamera
//
//  Created by Louis Harris on 6/26/17.
//  Copyright © 2017 Louis Harris. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

class Photo
{
    var photoURL:String!
    var photoImage:UIImage?
    //post
    var comments = [[String: String]]()
    var likes:Int?
    var uniqueID: String
    var storageID: String
    
    
    
    
    
    init(photoUrlString:String, uniqueID: String, storageID: String)
    {
        self.storageID = storageID
        self.photoURL = photoUrlString
        self.uniqueID = uniqueID
    }
    
    
    
    
}
