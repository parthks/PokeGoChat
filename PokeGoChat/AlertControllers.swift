//
//  AlertControllers.swift
//  Pikanect
//
//  Created by Parth Shah on 26/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import UIKit //for alert controllers



class AlertControllers {
	
	static func blockUserWithID(userID: String) {
		let alert = UIAlertController(title: "Are you sure you want to block this user?", message: "All messages from this user will be hidden", preferredStyle: .Alert)
		let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
		let blockButton = UIAlertAction(title: "Block!", style: .Destructive) { (alert) in
			Firebase.displayAlertWithtitle("Successfully Blocked User", message: "All messages from this user have been blocked")
			Firebase.saveNewBlockedUserWithId(userID)
		}
		
		alert.addAction(cancelButton)
		alert.addAction(blockButton)
		UIApplication.topViewController()!.presentViewController(alert, animated: true, completion: nil)
}
	
}