//
//  ViewController.swift
//  OTM
//
//  Created by arianne on 2015-09-30.
//  Copyright (c) 2015 della. All rights reserved.
//

import UIKit
import UIView_Shake

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    var pubDataGot:Bool = false
    var msg = ""
    var success = false
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        password.delegate = self
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        userName.resignFirstResponder()
        password.resignFirstResponder()
        
        return true
    }
    
    @IBAction func login(sender: AnyObject) {
        // force keyboard to resign
        view.endEditing(true)
        
        if ((userName.text!.isEmpty) && (password.text!.isEmpty)) {
            self.view.shake()
            msg  = "User name and password are empty"
            showError(msg)
            return
            
        } else if userName.text!.isEmpty {
            self.view.shake()
            msg  = "User name empty"
            showError(msg)
            return
            
        }
        else if ((userName.text! == "Email") && (password.text! == "Password"))  {
            // Shake
            msg  = "must enter username and password!"
            showError(msg)
            self.view.shake()
            return
        }
        else if userName.text! == "Email" {
            // Shake
            msg  = "must enter username"
            showError(msg)
            self.view.shake()
            return
        }
        else if password.text! == "Password" {
            // Shake
            msg  = "must enter password"
            showError(msg)
            self.view.shake()
            return
        }
        else if password.text!.isEmpty {
            // Shake
            msg  = "password empty"
            showError(msg)
            self.view.shake()
            return
        }
        else {
            let actInd = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            actInd.center = self.view.center
            actInd.hidesWhenStopped = true
            view.addSubview(actInd)
            actInd.startAnimating()
            ClientProcessing.sharedInstance().authenticateWithViewController(userName.text!, password: password.text!, completionHandler:{ (success, errorString) in
                if errorString == "1" {
                    actInd.stopAnimating()
                    dispatch_async(dispatch_get_main_queue(), {

                            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc : UITabBarController = storyboard.instantiateViewControllerWithIdentifier("toTabBar") as! UITabBarController
                            self.presentViewController(vc, animated: true, completion: nil)
                        
                    })
                 }
                
                else {
                    self.view.shake()
                    self.showError(errorString!)
                    actInd.stopAnimating()
                    return
                }
            })
        }
    }
    
 
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
      view.endEditing(true)
    }
    
    func showError(msg:String) {
        let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUP(sender: AnyObject) {
        let url:NSURL = NSURL(string: "https://www.udacity.com/account/auth#!/signup")!
        if UIApplication.sharedApplication().canOpenURL(url) {
            UIApplication.sharedApplication().openURL(url)
        } else {
            
            let alert = UIAlertController(title: "Error", message: "Invalid Link", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }

}

