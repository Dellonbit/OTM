//
//  User.swift
//  OTM
//
//  Created by arianne on 2015-09-30.
//  Copyright (c) 2015 della. All rights reserved.
//

import UIKit
struct User {
    var createdAt:NSDate
    var firstName:String!
    var lastName:String!
    var lat:Double!
    var long:Double!
    var mapString:String!
    var mediaURL:String!
    var objectId:String!
    var uniqueKey:String!
    var updatedAt:NSDate
        
    init(dictionary: NSDictionary) {
        createdAt = (dictionary["createdAt"] as? NSDate)!
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        lat = dictionary["latitude"] as! Double
        long = dictionary["longitude"] as! Double
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        objectId = dictionary["objectId"] as? String
        uniqueKey = dictionary["uniqueKey"] as? String
        updatedAt = (dictionary["updatedAt"] as? NSDate)!
    }
}
