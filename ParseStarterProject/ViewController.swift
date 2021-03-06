/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {
	
	// MARK: Properties
	
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	var mainSpinner: UIActivityIndicatorView!
	
	// MARK: Default actions

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
		
		// MARK: Initialize stuff
		
		// Main spinner
		mainSpinner = UIActivityIndicatorView( frame: self.view.frame )
		mainSpinner.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
		mainSpinner.center = self.view.center
		mainSpinner.hidesWhenStopped = true
		mainSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		self.view.addSubview(mainSpinner)
    }
	
	override func viewDidAppear(animated: Bool) {
		// check if there's an active user
		if PFUser.currentUser()?.objectId != nil {
			self.performSegueWithIdentifier("login", sender: self)
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// MARK: Login / Register actions
	
	@IBAction func tapLogin(sender: AnyObject) {
		var username = usernameTextField.text!
		var password = passwordTextField.text!
		
		// trim
		username = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		password = password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		
		// validate no empty
		if username.isEmpty == true || password.isEmpty == true {
			showAlert("Error", alertMessage: "Username and password are required")
		} else {
			// Login Parse user
			PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
				if user != nil {
					// MARK: Login successful
					
					// go to home screen
					self.performSegueWithIdentifier("login", sender: self)
				} else {
					let errorString = error?.userInfo["error"] as? String ?? "Please try again"
					self.showAlert("Error", alertMessage: errorString)
				}
			})
		}
	}
	
	@IBAction func tapRegister(sender: AnyObject) {
		var username = usernameTextField.text!
		var password = passwordTextField.text!
		
		// trim
		username = username.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		password = password.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		
		// validate no empty
		if username.isEmpty == true || password.isEmpty == true {
			showAlert("Error", alertMessage: "Username and password are required")
		} else {
			// Sign up Parse user
			let newUser = PFUser()
			newUser.username = username
			newUser.password = password
			
			newUser.signUpInBackgroundWithBlock({ (success, error) -> Void in
				self.hideMainSpinner()
				if success == false {
					let errorString = error?.userInfo["error"] as? String ?? "Please try again"
					self.showAlert("Error", alertMessage: errorString)
				} else {
					// MARK: Signup successful
					
					// go to home screen
					self.performSegueWithIdentifier("login", sender: self)
				}
			})
		}
	}
	
	// MARK: Utility fuctions
	
	func showAlert(alertTitle: String, alertMessage: String) -> Void {
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction( UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil) )
		presentViewController(alert, animated: true, completion: nil)
	}
	
	func showMainSpinner() {
		mainSpinner.startAnimating()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
	}
	
	func hideMainSpinner() {
		mainSpinner.stopAnimating()
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
	}
	
}
