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
	
	static func blockUserWithIDWithCompletionIfBlocked(userID: String, completion: () -> Void) {
		let alert = UIAlertController(title: "Are you sure you want to block this user?", message: "All messages from this user will be hidden", preferredStyle: .Alert)
		let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
		let blockButton = UIAlertAction(title: "Block!", style: .Destructive) { (alert) in
			AlertControllers.displayAlertWithtitle("Successfully Blocked User", message: "All messages from this user have been blocked")
			Firebase.saveNewBlockedUserWithId(userID)
			completion()
		}
		
		alert.addAction(cancelButton)
		alert.addAction(blockButton)
		UIApplication.topViewController()!.presentViewController(alert, animated: true, completion: nil)
	}
	
	static func displayErrorAlert(message: String, error: String, instance: String){
		let alert = UIAlertController(title: "ERROR!", message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
		let report = UIAlertAction(title: "Report", style: .Destructive) {e in
			//UIApplication.topViewController()?.dismissViewControllerAnimated(true, completion: nil)
			
			Firebase.saveError(error, DuringInstance: instance)
			displayAlertWithtitle("Error Message Confirmation", message: "Your error has been noted. Thank You for reporting.")
		}
		
		alert.addAction(report)
		UIApplication.topViewController()!.presentViewController(alert, animated: true, completion: nil)
	}
	
	static func displayAlertWithtitle(title: String, message: String){
		let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
		UIApplication.topViewController()!.presentViewController(alert, animated: true, completion: nil)
	}

	
}