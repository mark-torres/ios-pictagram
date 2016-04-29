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
	var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		
		// Refresher
		refresher = UIRefreshControl()
		refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
		refresher.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
		tableView.addSubview(refresher)
		
		// Main spinner
		mainSpinner = UIActivityIndicatorView( frame: self.view.frame )
		mainSpinner.backgroundColor = UIColor(white: 1.0, alpha: 0.5)
		mainSpinner.center = self.view.center
		mainSpinner.hidesWhenStopped = true
		mainSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
		self.view.addSubview(mainSpinner)

		currentUser = PFUser.currentUser()

		// load data
		refresh()
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
		if following[indexPath.row] == true {
			// Following, make unfollow
			following[indexPath.row] = false
			cell.accessoryType = UITableViewCellAccessoryType.None
			let query = PFQuery(className: "Follows")
			query.whereKey("followerId", equalTo: (currentUser?.objectId)!)
			query.whereKey("userId", equalTo: userIds[indexPath.row])
			showMainSpinner()
			query.findObjectsInBackgroundWithBlock { (result, error) -> Void in
				self.hideMainSpinner()
				let follows = result as [PFObject]? ?? [PFObject]()
				if follows.count > 0 {
					let follow = follows[0]
					follow.deleteInBackground()
				}
			}
		} else {
			// not following, make follow
			following[indexPath.row] = true
			cell.accessoryType = UITableViewCellAccessoryType.Checkmark
			let follow = PFObject(className: "Follows")
			follow["userId"] = userIds[indexPath.row]
			follow["followerId"] = currentUser.objectId
			showMainSpinner()
			follow.saveInBackgroundWithBlock({ (success, error) -> Void in
				self.hideMainSpinner()
			})
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
	
	func refresh() {
		print("refresh invoked")
		following = []
		usernames = []
		userIds = []
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
				self.refresher.endRefreshing()
				if let users = pfObjects as? [PFUser] {
					for user in users {
						if user.objectId != currentUser?.objectId {
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
	
	// MARK: Segues
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "feed" {
			// TODO: make a list of users followed and pass it to the feed
			followedUsers = [:]
			for (index, value) in userIds.enumerate() {
				if following[index] == true {
					followedUsers[ value ] = usernames[index]
				}
			}
		}
	}
}
