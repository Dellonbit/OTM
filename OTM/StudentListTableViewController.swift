//
//  StudentListTableViewController.swift
//  OTM
//
//  Created by arianne on 2015-10-01.
//  Copyright (c) 2015 della. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class StudentListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let logout = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self,action: Selector("logout"))
        navigationItem.leftBarButtonItem = logout
        
        let refreshBtn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("refreshBtnPressed"))
        
        let locateBtn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin-map-7.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("locateBtnPressed"))
        
        let buttons = [ refreshBtn, locateBtn]
        navigationItem.rightBarButtonItems = buttons
    }
    
    override func viewWillAppear(animated: Bool) {
        if let indexOfUser = ClientProcessing.studentList.indexOf({$0.uniqueKey == ClientProcessing.sharedInstance().userUniqueID}){
            if ((ClientProcessing.sharedInstance().userCoord != nil) && (ClientProcessing.sharedInstance().userLink != nil) && ClientProcessing.sharedInstance().userObjectID != nil) {
                ClientProcessing.sharedInstance().updateUserLocation()
            }
        }
        else if ((ClientProcessing.sharedInstance().userCoord != nil) && (ClientProcessing.sharedInstance().userLink != nil)){
            ClientProcessing.sharedInstance().parseUserPosting({ (success, error, result) -> Void in
                if success {
                    //successful posting
                
                }
                else {
                    let alert = UIAlertController(title: "Error", message: "No internet connection ", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
                
            })
        }

    }
    
    func locateBtnPressed (){
        // store data to app delegate
        let actInd = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        self.view.addSubview(actInd)
        actInd.startAnimating()
        
        ClientProcessing.sharedInstance().queryUserLocation()
        print("quering here instead")
        
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        if let indexOfUser = ClientProcessing.studentList.indexOf({$0.uniqueKey == ClientProcessing.sharedInstance().userUniqueID}){
            actInd.stopAnimating()
            let alert = UIAlertController(title: nil, message: "You Have Already Posted A Student Location. Would You Like To Overwrite Your Current Location?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.Default, handler: { (alertAction) -> Void in
                self.overWriteHandler()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            return
        }
        else{
            actInd.stopAnimating()
            performSegueWithIdentifier("userMaptoNav", sender: self)
        }
    }
    
    func overWriteHandler () {
        performSegueWithIdentifier("userMaptoNav", sender: self)
    }
    
    
    func convertDateFormater(date: String) -> NSDate
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(date)
        return date!
    }
    
    func refreshBtnPressed() {
        let actInd = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        self.view.addSubview(actInd)
        actInd.startAnimating()
        
        ClientProcessing.sharedInstance().getStudentsData { (success, error, result) -> Void in
            
            if success{
                actInd.stopAnimating()
            }
            else {
                actInd.stopAnimating()
                let alert = UIAlertController(title: "Error", message: error as String , preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
            
        }
    }

    func logout() {
        ClientProcessing.sharedInstance().logout()
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //display student data
        return ClientProcessing.studentList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! StudentListTableViewCell

        // sort in ascending order by date updated.
        ClientProcessing.studentList.sortInPlace({ $0.updatedAt.timeIntervalSince1970 > $1.updatedAt.timeIntervalSince1970 })
        
        //create student object
        let stuData = ClientProcessing.studentList[indexPath.row]
        cell.imageView?.image = UIImage(named: "pin-map-7")
        cell.textLabel?.text = "\(stuData.firstName) \(stuData.lastName)"
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selStud = ClientProcessing.studentList[indexPath.row]
        let url:NSURL = NSURL(string: selStud.mediaURL)!
        
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Invalid Link", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
}
