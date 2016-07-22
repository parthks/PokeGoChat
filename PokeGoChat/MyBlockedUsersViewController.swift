//
//  MyBlockedUsersViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 18/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

class MyBlockedUsersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

	var blockedUsers: [User] = []
	var currentlyBlocked: [Bool] = []
	
	@IBAction func save(sender: UIBarButtonItem) {
	
		for index in 0..<blockedUsers.count {
			if !currentlyBlocked[index] {
				Firebase.removeBlockedUserWithId(blockedUsers[index].id)
			}
		}
		print("going back to profile")
		self.navigationController?.popViewControllerAnimated(true)
		
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		Firebase.removeListeningForBlockedUsers()
	}
	
	@IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
		
		Firebase.getAllBlockedUsersForCurrentUserWithBlock(){ [unowned self] allblockedUsers in
			for key in allblockedUsers {
				Firebase.getUserDataWithKey(key) { user in
					self.blockedUsers.append(user!)
					self.currentlyBlocked.append(true)
					self.tableView.reloadData()
				}

			}
		}
        // Do any additional setup after loading the view.
    }

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		currentlyBlocked[indexPath.row] = !currentlyBlocked[indexPath.row]
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		tableView.reloadData()
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return blockedUsers.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		cell.textLabel?.text = blockedUsers[indexPath.row].name
		if currentlyBlocked[indexPath.row]{
			cell.detailTextLabel?.text = "Blocked!"
		}else {
			cell.detailTextLabel?.text = "Not Blocked"
		}
		
		return cell
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

}
