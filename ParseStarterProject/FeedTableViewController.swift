//
//  FeedTableViewController.swift
//  Pictagram
//
//  Created by Mark Torres on 4/29/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class FeedTableViewController: UITableViewController {
	
	var posts: [PFObject]!
	
	var mainSpinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		// Main spinner
		mainSpinner = UIActivityIndicatorView( frame: self.view.frame )
		mainSpinner.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
		mainSpinner.center = self.view.center
		mainSpinner.hidesWhenStopped = true
		mainSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		self.view.addSubview(mainSpinner)
		
		// option 1: get the followed user ids from previous view
		// option 2: get the followed user ids with Follows class
		
		// load posts from followed users
		posts = []
		if followedUsers.count > 0 {
			let followedIds = Array(followedUsers.keys)
			let predicateFormat: String = "userId IN {'" + followedIds.joinWithSeparator("','") + "'}"
			let postsPredicate = NSPredicate(format: predicateFormat, argumentArray: nil)
			let postsQuery = PFQuery(className: "Posts", predicate: postsPredicate)
			postsQuery.findObjectsInBackgroundWithBlock({ (objects:[PFObject]?, error: NSError?) -> Void in
				self.posts = objects ?? []
				self.tableView.reloadData()
			})
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return posts.count
    }

	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell

		let post = posts[indexPath.row]
		let userIds = Array(followedUsers.keys)
		let userId = post["userId"] as? String ?? "username"
		
        // Configure the cell...
		cell.postImageView.image = UIImage(named: "image-placeholder.png")
		cell.usernameLabel.text = userIds.indexOf(userId) != nil ? followedUsers[userId] : "username"
		cell.messageLabel.text = post["message"] as? String ?? "Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor."
		
		// load the image
		let imageFile = post["image"] as! PFFile
		imageFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
			if error == nil {
				if let imageData = imageData {
					let image = UIImage(data: imageData)
					cell.postImageView.image = image!
				}
			}
		}
		
        return cell
    }
	

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

	// MARK: Utility functions
	
	func showMainSpinner() {
		mainSpinner.startAnimating()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
	}
	
	func hideMainSpinner() {
		mainSpinner.stopAnimating()
		UIApplication.sharedApplication().endIgnoringInteractionEvents()
	}
}
