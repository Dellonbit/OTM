//
//  ClientApi.swift
//  OTM
//
//  Created by arianne on 2015-11-11.
//  Copyright © 2015 della. All rights reserved.
//
// convenience class
import UIKit
import MapKit
import CoreLocation

extension ClientProcessing {
    
    
    func authenticateWithViewController(username:String, password:String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        /* Chain completion handlers for each request so that they run one after the other */
        processLogin(username, password: password, completion: { (success, error , result) in
        
            if success {
                
                let results = result.objectForKey("account") as? NSDictionary
                let userSession = result.objectForKey("session") as! NSDictionary
                let isRegistered: AnyObject = results!.objectForKey("registered")! as! Bool
                let uniqueUserId: AnyObject = results!.objectForKey("key")!
                let sessionId: AnyObject = userSession.objectForKey("id")!
                self.userUniqueID = uniqueUserId as! String
                completionHandler(success: success, errorString: "1")
                self.getPublicData (uniqueUserId as! String, completionHandler: { (success, errorString, result) -> Void in
                    if success{
                        //nothing to do here
                    }
                    else {
                        completionHandler (success: success, errorString: errorString)
                    }
               })
               
            }
            else {
                
                completionHandler(success: success, errorString: error as String)
            }
            
        })
   }

    
    func processLogin (userName:String, password:String, completion:(success:Bool, error: NSString, result: NSDictionary) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(userName)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                var errordict = ["error": "error" ]
                completion(success:false, error: "network error", result: errordict)
                return
            }
            else {
                //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                // Parse data
                //var  jsonDict:NSDictionary!
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                var result = (try! NSJSONSerialization.JSONObjectWithData(newData, options: [])) as! NSDictionary
                //completion(success: true, error: "no error", result: jsonDict)
                
                //check returned json for errors and use data
                if (error == "error"){
                    completion(success: false, error: "No internet connection", result: result)
                    return
                }
                
                if((result.objectForKey("error")) != nil){
                    completion(success: false, error: "Account not found or invalid credentials", result: result)
                    return 
                    
                }
                else if (result.count<=0) {
                    completion(success: false, error: "login error", result: result)
                    return
                }else{
                completion(success: true, error: "no error", result: result)
            
                }
            }
        }
        task.resume()
    }

    func getPublicData (uniqueid:String, completionHandler: (success: Bool, errorString: String?, result: NSDictionary) -> Void){
        // store data to app delegate
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        dispatch_async(dispatch_get_main_queue(), {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.userUniqueID)")!)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error...
                    //request timedout error
                    var errordict = ["error": "error" ]
                    completionHandler (success: false, errorString: "couldn't download user data", result: errordict)
                    return
                }
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                
                var jsonError: NSError?
                let jsonDict = (try! NSJSONSerialization.JSONObjectWithData(newData, options: [])) as! NSDictionary
                
                if !(jsonError != nil) {
                    var firstName: String!
                    var lastName: String!
                    var results = jsonDict.objectForKey("user") as! NSDictionary
                    if (!((results.objectForKey("last_name")) is NSNull)) {
                        self.userLastName = results.objectForKey("last_name")! as! String
                    }
                    if (!((results.objectForKey("first_name")) is NSNull)){
                        self.userFirstName = results.objectForKey("first_name")! as! String
                        print(self.userUniqueID + " " + self.userFirstName)
                        
                    }
                    completionHandler (success: true, errorString: "no error", result: jsonDict)
                }
            }
            task.resume()
        })
    
    }
    
    func proceedLogin( hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
         dispatch_async(dispatch_get_main_queue(), {

        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let vc : UITabBarController = storyboard.instantiateViewControllerWithIdentifier("toTabBar") as! UITabBarController
                                    hostViewController.presentViewController(vc, animated: true, completion: nil)

            
        })
    
    }

    
    func getStudentsData(completion:(success: Bool, error: NSString, result: NSDictionary) -> Void) {
        // store data to app delegate
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            , forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if (error != nil) { // Handle error...
                //print("request error")
                var errordict = ["error": "error" ]
                completion(success: false, error: "No internet connection", result: errordict)
            }
            else{
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
                //    var jsonError: NSError? = nil
                let result =  (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments )) as! NSDictionary
                //return result
                //completion(success: true ,error: "no error", result: parsedResult)
                if error == "error" {
                    var errordict = ["error":"error"]
                    completion(success: false, error: "error downloading students data ", result: errordict)
                    return
                }
                
                if(( result.objectForKey("error")) != nil){
                    var errordict = ["error":"error"]
                   completion(success: false, error: "Error downloading data", result: errordict)

                    return
                }
                
                if let locations = result["results"] as? [[String:AnyObject]] {
                    // remove any data first from array
                    ClientProcessing.studentList = [ ]
                    ClientProcessing.pins = []
                    dispatch_async(dispatch_get_main_queue(), {
                        for k in locations{
                            let st = k as NSDictionary
                            //println (st["firstName"]!)
                            let createdat =  st["createdAt"]! as! String
                            let datecreated = self.convertDateFormater(createdat)
                            let firstname = st["firstName"]! as! String
                            let lastname = st["lastName"]! as! String
                            let lat = st["latitude"]! as! Double
                            let long = st["longitude"]! as! Double
                            let mapstring = st["mapString"]! as! String
                            let mediaUrl = st["mediaURL"]! as! String
                            let objectId = st["objectId"]! as! String
                            let uniquekey = st["uniqueKey"]! as! String
                            let updatedAt = st["updatedAt"]! as! String
                            let dateupdated = self.convertDateFormater(updatedAt)
                            let mydict = ["createdAt": datecreated, "firstName": firstname, "lastName": lastname, "latitude": lat, "longitude": long, "mapString": mapstring, "mediaURL": mediaUrl, "objectId": objectId, "uniqueKey": uniquekey, "updatedAt": dateupdated]
                            let studentinfo2 = User(dictionary: mydict)
                            ClientProcessing.studentList.append(studentinfo2)
                        }
                        
                        for object in ClientProcessing.studentList {
                            let lat = object.lat
                            let long = object.long!
                            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            let mediaURL = object.mediaURL
                            let pin = MKPointAnnotation()
                            pin.coordinate = coordinate
                            pin.title = "\(object.firstName) \(object.lastName)"
                            pin.subtitle = mediaURL
                            ClientProcessing.pins.append(pin)
                        }
                        completion(success: true, error: "No error", result: result)
                    })
                }
            }
        }
        task.resume()
    }
    
    
    func convertDateFormater(date: String) -> NSDate
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(date)
        return date!
    }
    
    func parseUserPosting(completion:( success: Bool, error: NSString, result: NSDictionary) -> Void) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        var lat: Double = Double((self.userCoord?.latitude)!)
        var long: Double = Double((self.userCoord?.longitude)!)
        dispatch_async(dispatch_get_main_queue(), {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
            request.HTTPMethod = "POST"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.HTTPBody = "{\"uniqueKey\": \"\(self.userUniqueID)\", \"firstName\": \"\(self.userFirstName)\", \"lastName\": \"\(self.userLastName)\",\"mapString\": \"\(self.userAddress)\", \"mediaURL\": \"\(self.userLink)\",\"latitude\": \(lat), \"longitude\": \(long)}".dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    var errordict = ["error": "error" ]
                    completion(success: false, error: "error", result: errordict)
                    return
                }
                var errordict = ["error": "no error" ]
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                completion(success: true, error: "no error", result: errordict)
            }
            task.resume()
        })
    }
    
    func queryUserLocation() {
        
        
        dispatch_async(dispatch_get_main_queue(), {
            
            let urlString = "https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%22\(self.userUniqueID)%22%7D"
            let url = NSURL(string: urlString)
            let request = NSMutableURLRequest(URL: url!)
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { /* Handle error */
                    return
                }
                else {
                    // print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                    let parsedResult =  (try! NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.AllowFragments )) as! NSDictionary
                    let results: NSArray =  (parsedResult["results"] as? NSArray)!
                    let aStatus = results[0] as? NSDictionary
                    let user = aStatus!.objectForKey("objectId") as? String
                    self.userObjectID = user!
                    print (self.userObjectID)
                }
            }
            task.resume()
        })
        
    }
    
    
    
    
    func updateUserLocation (){
        
        print(self.userUniqueID)
        var lat: Double = Double((self.userCoord?.latitude)!)
        var long: Double = Double((self.userCoord?.longitude)!)
        
        dispatch_async(dispatch_get_main_queue(), {
            let urlString = "https://api.parse.com/1/classes/StudentLocation/\(self.userObjectID)"
            let url = NSURL(string: urlString)
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "PUT"
            request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            request.HTTPBody = "{\"uniqueKey\": \"\(self.userUniqueID)\", \"firstName\": \"\(self.userFirstName)\", \"lastName\": \"\(self.userLastName)\",\"mapString\": \"\(self.userAddress)\", \"mediaURL\": \"\(self.userLink)\",\"latitude\": \(lat), \"longitude\": \(long)}".dataUsingEncoding(NSUTF8StringEncoding)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error != nil { // Handle error…
                    return
                }
                print(NSString(data: data!, encoding: NSUTF8StringEncoding))
            }
            task.resume()
        })
    }
    
    func logout(){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            else{
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                //print(NSString(data: newData, encoding: NSUTF8StringEncoding))
                
            }
        }
        task.resume()
    }
    
}//end of class
