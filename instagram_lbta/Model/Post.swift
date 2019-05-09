//
//  Post.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 2.06.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import UIKit

@objcMembers
class Post: NSObject {
    var id: String?
    var imageUrl: String?
    var comment: String?
    var postedById: String?
    var postedByUsername: String?
    var timestamp: NSNumber?
    var likeCount: NSNumber?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        imageUrl = dictionary["imageUrl"] as? String
        comment = dictionary["comment"] as? String
        postedById = dictionary["postedById"] as? String
        postedByUsername = dictionary["postedByUsername"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
    }
}
