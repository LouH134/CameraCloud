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
    //photo url
    var photoURL:String!
    //image
    var photoImage:UIImage?
    //post
    var comment:String? //make an array of comments
    var likes:Int?
    var uniqueID: String
    
    
    
    
    
    init(photoUrlString:String, uniqueID: String)
    {
        self.photoURL = photoUrlString
        self.uniqueID = uniqueID
    }
    
    
    
    
}
