//
//  UserLocMapViewController.swift
//  OTM
//
//  Created by arianne on 2015-10-01.
//  Copyright (c) 2015 della. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class UserLocMapViewController: UIViewController, MKMapViewDelegate  {

    @IBOutlet weak var userMap: MKMapView!
    var userlink: String?
    var userCoordnates: CLLocationCoordinate2D?
    var userLocAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let logout = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Plain, target: self,action: Selector("logout"))
        navigationItem.leftBarButtonItem = logout
        
        let refreshBtn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "refresh.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("refreshBtnPressed"))
        
        let locateBtn : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin-map-7.png"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("locateBtnPressed"))
        
        let buttons = [ refreshBtn, locateBtn]
        navigationItem.rightBarButtonItems = buttons
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        userMap.delegate = self
    }
    
     override func viewWillAppear(animated: Bool) {
        let object = UIApplication.sharedApplication().delegate
        let appDelegate = object as! AppDelegate
        
        if ClientProcessing.pins.count>0{
            userMap.removeAnnotations(userMap.annotations)
            getStudentLocations()
        }
        else {
            // get data and plot
            getStudentLocations()
            
        }
        
        
        if let indexOfUser = ClientProcessing.studentList.indexOf({$0.uniqueKey == ClientProcessing.sharedInstance().userUniqueID}){
            if ((ClientProcessing.sharedInstance().userCoord != nil) && (ClientProcessing.sharedInstance().userLink != nil) && ClientProcessing.sharedInstance().userObjectID != nil) {
               
                ClientProcessing.sharedInstance().updateUserLocation()
                
            }
        }
        else if ((ClientProcessing.sharedInstance().userCoord != nil) && (ClientProcessing.sharedInstance().userLink != nil)){
            
            ClientProcessing.sharedInstance().parseUserPosting({ (success, error, result) -> Void in
                if success {
                    //posting successful
                }
                else{
                    let alert = UIAlertController(title: "Error", message: "No internet connection ", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    return
                }
            })
        }
    }
    
    func convertDateFormater(date: String) -> NSDate
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let date = dateFormatter.dateFromString(date)
        return date!
    }
    
    func getStudentLocations() {
        let actInd = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        self.view.addSubview(actInd)
        actInd.startAnimating()
        
        ClientProcessing.sharedInstance().getStudentsData { (success, error, result) -> Void in
            if success {
                for pin in ClientProcessing.pins{
                  self.userMap.addAnnotation(pin)
                }
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
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    func mapView(mapView: MKMapView,
        viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation{
                return nil
            }
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
            
            if(pinView == nil){
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.animatesDrop = true
                pinView!.pinColor = .Red
                
                let calloutButton = UIButton(type: .DetailDisclosure)
                pinView!.rightCalloutAccessoryView = calloutButton
            } else {
                pinView!.annotation = annotation
            }
            return pinView!
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            
            if UIApplication.sharedApplication().canOpenURL(NSURL(string: annotationView.annotation!.subtitle!!)!) {
                UIApplication.sharedApplication().openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
            } else {
                
                let alert = UIAlertController(title: "Error", message: "Invalid Link", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    func locateBtnPressed (){
        // store data to app delegate
        let actInd = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        actInd.center = self.view.center
        actInd.hidesWhenStopped = true
        self.view.addSubview(actInd)
        actInd.startAnimating()
        
        //querry first
        ClientProcessing.sharedInstance().queryUserLocation()
        print("quering here instead")
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
    
    func refreshBtnPressed() {
        // remove all pins
        userMap.removeAnnotations(userMap.annotations)
        // get new data
        getStudentLocations()
    }
    
}
