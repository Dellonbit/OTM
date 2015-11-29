//
//  UserLocViewController.swift
//  OTM
//
//  Created by arianne on 2015-10-01.
//  Copyright (c) 2015 della. All rights reserved.
//

import UIKit
import MapKit

class UserLocViewController: UIViewController,MKMapViewDelegate, UITextViewDelegate, UITextFieldDelegate {

    var userAddress:String!
    var coordinates: CLLocationCoordinate2D?
    
    @IBOutlet weak var wherareyou: UILabel!
    @IBOutlet weak var studyLab: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    
    @IBOutlet weak var userMap: MKMapView!
    
    @IBOutlet weak var Linktxt: UITextField!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var locationInPutButton: UIButton!
    @IBOutlet weak var locationtxt: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationtxt.delegate = self
        Linktxt.delegate = self
        
    }
    
    @IBAction func Cancel(sender: AnyObject) {
       dismissViewControllerAnimated(true, completion: nil)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        locationInPutButton.layer.cornerRadius = 5.0
        Linktxt.hidden = true
        userMap.hidden = true
        locationtxt.hidden = false
        transparentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        locationInPutButton.setTitle("Find on the Map", forState: UIControlState.Normal)
    }
    
    @IBAction func locationInputBut(sender: AnyObject) {
        if (locationInPutButton.titleLabel?.text  == "Find on the Map") {
            let actInd = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            actInd.center = self.view.center
            actInd.hidesWhenStopped = true
            self.view.addSubview(actInd)
            actInd.startAnimating()
            
            //change button
            locationInPutButton.setTitle("Submit", forState: UIControlState.Normal)
            
            // hide following
            wherareyou.hidden = true
            todayLabel.hidden = true
            locationtxt.hidden = true
            studyLab.hidden = true
        
            //unhide the following
            userMap.hidden = false
            //transparentView.hidden = false
            transparentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
            Linktxt.hidden = false
        
            self.view.backgroundColor = UIColor(red: 0, green: 251, blue: 255, alpha: 1.0)
        
            userAddress = locationtxt.text
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(userAddress, completionHandler: {(placemarks, error) -> Void in
                if (error != nil) {
                   if (error!.code == 2) {
                        //unhide following
                        self.wherareyou.hidden = false
                        self.todayLabel.hidden = false
                        self.locationtxt.hidden = false
                        self.studyLab.hidden = false
                        
                        //hide the following
                        self.userMap.hidden = true
                        self.transparentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
                        self.Linktxt.hidden = true
                        //change button
                        self.locationInPutButton.setTitle("Find on the Map", forState: UIControlState.Normal)
                        self.view.backgroundColor = UIColor(red: 246, green: 227, blue: 130, alpha: 1.0)
                        //stop animation
                        actInd.stopAnimating()
                        print(error!.code)
                        let alert = UIAlertController(title: "Error", message: "No internet Connection" , preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                        
                    }
                    else if (error!.code == 8 ) {
                        //unhide following
                        self.wherareyou.hidden = false
                        self.todayLabel.hidden = false
                        self.locationtxt.hidden = false
                        self.studyLab.hidden = false
                        
                        //hide the following
                        self.userMap.hidden = true
                        self.transparentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
                        self.Linktxt.hidden = true
                        
                        //change button
                        self.locationInPutButton.setTitle("Find on the Map", forState: UIControlState.Normal)
                        self.view.backgroundColor = UIColor(red: 246, green: 227, blue: 130, alpha: 1.0)
                        actInd.stopAnimating()
                        print(error!.code)
                        let alert = UIAlertController(title: "Error", message: "Can't find location on Map" , preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        return
                    }
            }
            else if let placemark: AnyObject = placemarks?[0] {
                //unhide following
                self.wherareyou.hidden = true
                self.todayLabel.hidden = true
                self.locationtxt.hidden = true
                self.studyLab.hidden = true
                
                //hide the following
                self.userMap.hidden = false
                self.transparentView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
                self.Linktxt.hidden = false
                
                self.coordinates = placemark.location!!.coordinate
                let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01 , 0.01)
                let region:MKCoordinateRegion = MKCoordinateRegionMake(self.coordinates!, span)
                
                let pointAnnotation:MKPointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = self.coordinates!
                self.userMap.addAnnotation(pointAnnotation)
                self.userMap.centerCoordinate = self.coordinates!
                self.userMap.setRegion(region, animated: true)
                self.userMap.selectAnnotation(pointAnnotation, animated: true)
                self.userMap.userInteractionEnabled = false
            }
            actInd.stopAnimating()
        })
       actInd.stopAnimating()     
      }
      else if (locationInPutButton.titleLabel?.text  == "Submit"){
        
            if ((Linktxt!.text == "Enter A link To Share Here") || (Linktxt.text!.isEmpty || Linktxt.text == nil)) {
                let alert = UIAlertController(title: nil, message: "Must enter a link", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
                return
            }
             else {
                    if ( (( NSURL(string: Linktxt.text!)) != nil) && UIApplication.sharedApplication().canOpenURL( NSURL(string: Linktxt.text!)!)) {
                        // retrieve data from app delegate
                        ClientProcessing.sharedInstance().userLink = Linktxt.text
                        ClientProcessing.sharedInstance().userCoord = coordinates
                        ClientProcessing.sharedInstance().userAddress = locationtxt.text
                        
                        let pin = MKPointAnnotation()
                        if (ClientProcessing.sharedInstance().userCoord != nil){
                            ClientProcessing.pins.removeLast()
                            pin.coordinate = coordinates!
                            pin.title = "\(ClientProcessing.sharedInstance().userFirstName) \(ClientProcessing.sharedInstance().userLastName)"
                            pin.subtitle = ClientProcessing.sharedInstance().userLink
                            ClientProcessing.pins.append(pin)
                            dismissViewControllerAnimated(true, completion: nil)
                        }
                        else{
                            pin.coordinate = coordinates!
                            pin.title = "\(ClientProcessing.sharedInstance().userFirstName) \(ClientProcessing.sharedInstance().userLastName)"
                            pin.subtitle = ClientProcessing.sharedInstance().userLink
                            ClientProcessing.pins.append(pin)
                            dismissViewControllerAnimated(true, completion: nil)
                            
                            }
                    }
                    else {
                        let alert = UIAlertController(title: "Error", message: "Invalid link. Include HTTP(s)://", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                        presentViewController(alert, animated: true, completion: nil)
                        return
                     }
              }
        }
    
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        Linktxt.resignFirstResponder()
        return true
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        locationtxt.text = " "
        locationtxt.textAlignment = .Left
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        Linktxt.resignFirstResponder()
        view.endEditing(true)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        locationtxt.textAlignment = .Center
        locationtxt.resignFirstResponder()
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if((text == "\n")) {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
