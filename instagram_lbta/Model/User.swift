//
//  User.swift
//  instagram_lbta
//
//  Created by Gokhan Demirer on 10.05.2018.
//  Copyright © 2018 Gokhan Demirer. All rights reserved.
//

import Foundation

@objcMembers
class User: NSObject {
    var id: String?
    var name:String?
    var bio: String?
    var website: String?
    var email:String?
    var username:String?
    var postCount: NSNumber?
    var followerCount: NSNumber?
    var followCount: NSNumber?
    var profileImageUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
        username = dictionary["username"] as? String
        bio = dictionary["bio"] as? String
        website = dictionary["website"] as? String
        postCount = dictionary["postCount"] as? NSNumber
        followerCount = dictionary["followerCount"] as? NSNumber
        followCount = dictionary["followCount"] as? NSNumber
        profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
