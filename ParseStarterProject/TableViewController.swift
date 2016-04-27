//
//  TableViewController.swift
//  Pictagram
//
//  Created by Mark Torres on 4/27/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
	
	var usernames: [String]!
	var userIds: [String]!
	var following: [Bool]!
	var mainSpinner: UIActivityIndicatorView!
	var currentUser: PFUser!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		// Main spinner
		mainSpinner = UIActivityIndicatorView( frame: CGRect(x: 0, y: 0, width: 80, height: 80)	)
		mainSpinner.center = self.view.center
		mainSpinner.hidesWhenStopped = true
		mainSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		self.view.addSubview(mainSpinner)

		following = []
		usernames = []
		userIds = []
		currentUser = PFUser.currentUser()

		// get follows data
		let followsQuery = PFQuery(className: "Follows")
		followsQuery.whereKey("followerId", equalTo: (currentUser?.objectId)!)
		showMainSpinner()
		followsQuery.findObjectsInBackgroundWithBlock { (followsResult, error) -> Void in
			self.hideMainSpinner()
			// get users followed by current user
			var followingIds: [String] = []
			if let follows = followsResult {
				for follow in follows {
					let userId = follow["userId"] as? String ?? ""
					if userId.isEmpty == false {
						followingIds.append(userId)
					}
				}
			}
			print(followingIds)
			
			// get users list
			var parseUsers = [String:String]()
			let query = PFUser.query()
			self.showMainSpinner()
			query?.findObjectsInBackgroundWithBlock({ (pfObjects, error) -> Void in
				self.hideMainSpinner()
				if let users = pfObjects as? [PFUser] {
					for user in users {
						if user.objectId != self.currentUser?.objectId {
							parseUsers[user.username!] = user.objectId!
						}
					}
				}
				// sort by username ascending (<)
				// http://www.timdietrich.me/blog/swift-sorting-dictionaries-by-keys/
				let unsortedUsernames = Array(parseUsers.keys)
				self.usernames = unsortedUsernames.sort(<)
				for username in self.usernames {
					self.userIds.append(parseUsers[username]!)
					let followedUser = followingIds.indexOf(parseUsers[username]!) != nil ? true : false
					self.following.append(followedUser)
				}
				print(self.usernames)
				print(self.userIds)
				
				// reload table data
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
        return usernames.count
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...
		cell.textLabel?.text = usernames[indexPath.row]
		
		if following[indexPath.row] == true {
			cell.accessoryType = UITableViewCellAccessoryType.Checkmark
		} else {
			cell.accessoryType = UITableViewCellAccessoryType.None
		}

        return cell
    }

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print(indexPath.row)
		let cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
		
		// TODO: Save follow / unfollow to parse

//		let query = PFQuery(className: "Follows")
//		query.whereKey("followerId", equalTo: (currentUser?.objectId)!)
//		showMainSpinner()
//		query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
//			if let follows = result {
//				
//			}
//		}
//		
//		if following[indexPath.row] == true {
//			// Following, make unfollow
//			following[indexPath.row] = false
//		} else {
//			// not following, make follow
//			following[indexPath.row] = true
//		}
		
		following[indexPath.row] = !following[indexPath.row]
		if following[indexPath.row] == true {
			cell.accessoryType = UITableViewCellAccessoryType.Checkmark
		} else {
			cell.accessoryType = UITableViewCellAccessoryType.None
		}
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

	// MARK: Utility fuctions
	
	func showAlert(alertTitle: String, alertMessage: String) -> Void {
		let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction( UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action)-> Void in
			self.dismissViewControllerAnimated(true, completion: nil)
		}) )
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
