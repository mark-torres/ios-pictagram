//
//  PostViewController.swift
//  Pictagram
//
//  Created by Mark Torres on 4/28/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
	
	@IBOutlet weak var postImageView: UIImageView!
	@IBOutlet weak var postTextField: UITextField!
	
	var mainSpinner: UIActivityIndicatorView!
	
	// MARK: Default

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		
		// Main spinner
		mainSpinner = UIActivityIndicatorView( frame: self.view.frame )
		mainSpinner.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
		mainSpinner.center = self.view.center
		mainSpinner.hidesWhenStopped = true
		mainSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		self.view.addSubview(mainSpinner)
		
		resetForm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	// MARK: Tap actions
	
	@IBAction func tapPickImage(sender: AnyObject) {
		// Load image from library
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
		// imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
		self.presentViewController(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func tapPostImage(sender: AnyObject) {
		// Save image to Parse

		// validate image
		if postImageView.image?.isEqual( UIImage(named: "image-placeholder.png") ) == true {
			showAlert("Warning!", alertMessage: "You need to pick an image")
			return
		}
		
		// validate message
		let message = postTextField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
		if message!.isEmpty == true {
			showAlert("Warning!", alertMessage: "Message is empty")
			return
		}
		
		// validate data size
		let imageData = UIImageJPEGRepresentation(postImageView.image!, 0.9)
		let maxSize: Int = 1024 * 1024 * 10
		if imageData?.length > maxSize {
			showAlert("Warning!", alertMessage: "Image data is more than 10 MB")
			return
		}
		
		let parseFile = PFFile(name: "picture.jpeg", data: imageData!)
		
		let post = PFObject(className: "Posts")
		post["userId"] = PFUser.currentUser()?.objectId
		post["image"] = parseFile
		post["message"] = postTextField.text!
		
		showMainSpinner()
		post.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
			self.hideMainSpinner()
			self.resetForm()
		}
	}
	
	// MARK: UIImagePickerController delegates
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
		self.dismissViewControllerAnimated(true, completion: nil)
		
		// Resize image before loading
		// Image resizing: http://nshipster.com/image-resizing/
		// Use UIKit
		// max size = 1024 pix
		let maxSize: CGFloat = 1024.0
		if image.size.width > maxSize || image.size.height > maxSize {
			showMainSpinner()
			
			var ratio: CGFloat = 0.0
			if image.size.width > image.size.height {
				ratio = maxSize / image.size.width
			} else {
				ratio = maxSize / image.size.height
			}
			
			let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(ratio, ratio))
			let hasAlpha = false
			let scale: CGFloat = 1.0 // Use 1
			
			UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
			image.drawInRect(CGRect(origin: CGPointZero, size: size))
			
			let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
			
			hideMainSpinner()
			print(scaledImage.size)
			postImageView.image = scaledImage
		} else {
			print(image.size)
			postImageView.image = image
		}
	}
	
	// MARK: Utility functions
	
	func showAlert(alertTitle: String, alertMessage: String) -> Void {
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction( UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil) )
		presentViewController(alert, animated: true, completion: nil)
	}
	
	func resetForm() {
		postImageView.image = UIImage(named: "image-placeholder.png")
		postTextField.text = ""
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
