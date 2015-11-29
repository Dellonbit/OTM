//
//  ClientProcessing.swift
//  
//
//  Created by arianne on 2015-11-10.
//
//

import UIKit
import MapKit

class ClientProcessing: NSObject {
    // current users infor
    var userLink:String!
    var userCoord: CLLocationCoordinate2D?
    var userAddress: String!
    var userFirstName: String!
    var userLastName: String!
    var userUniqueID: String!
    var userObjectID: String!
    static var pins = [MKAnnotation]()
    static var studentList = [User]()
    
    
    // MARK: - Shared Instance: singleton class
    class func sharedInstance() -> ClientProcessing {
        
        struct Singleton {
            static var sharedInstance = ClientProcessing()
        }
        
        return Singleton.sharedInstance
    }

    

} // end of processing