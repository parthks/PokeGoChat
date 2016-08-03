//
//  AlertControllers.swift
//  Pikanect
//
//  Created by Parth Shah on 26/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import UIKit //for alert controllers
import SystemConfiguration //for connected to internet function



class AlertControllers {
	
	static func reportUserWithIDWithCompletionIfReported(userID: String, messageText: String, completion: () -> Void) {
		let alert = UIAlertController(title: "Are you sure you want to report this message?", message: messageText, preferredStyle: .Alert)
		let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
		let reportButton = UIAlertAction(title: "Report!", style: .Destructive) { (alert) in
			AlertControllers.displayAlertWithtitle("Reported Message Confirmation", message: "The meesage has been reported to the admins")
			completion()
		}
		
		alert.addAction(cancelButton)
		alert.addAction(reportButton)
		
		UIApplication.topViewController()!.presentViewController(alert, animated: true, completion: nil)
	}
	
	
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
	
	
	
	
	static func rateMyApp() {
		let alert = UIAlertController(title: "Rate Pikanect", message: "How do you like this app? We would love to hear your feedback ", preferredStyle: .Alert)
		let rateButton = UIAlertAction(title: "Rate Now!", style: .Cancel) { (alert) in
			UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1136003010")!)
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "doneAppRating")
			
		}
		
		let dontWantToRate = UIAlertAction(title: "Never remind me again!", style: .Destructive) { (alert) in
			NSUserDefaults.standardUserDefaults().setBool(true, forKey: "doneAppRating")
		}
		
		
		let remindLater = UIAlertAction(title: "Remind Me Later", style: .Cancel) { alert in
			NSUserDefaults.standardUserDefaults().setBool(false, forKey: "doneAppRating")
			NSUserDefaults.standardUserDefaults().setBool(false, forKey: "quitApp")
		}
		
		
		alert.addAction(dontWantToRate)
		alert.addAction(remindLater)
		alert.addAction(rateButton)
		
		UIApplication.topViewController()!.presentViewController(alert, animated: true, completion: nil)
	}

	
}


extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
	
	
	
	func connectedToNetwork() -> Bool {
		
		var zeroAddress = sockaddr_in()
		zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
		zeroAddress.sin_family = sa_family_t(AF_INET)
		
		guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
			SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
		}) else {
			return false
		}
		
		var flags : SCNetworkReachabilityFlags = []
		if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
			return false
		}
		
		let isReachable = flags.contains(.Reachable)
		let needsConnection = flags.contains(.ConnectionRequired)
		
		// let isReachable = flags.contains(.reachable)
		// let needsConnection = flags.contains(.connectionRequired)
		
		
		return (isReachable && !needsConnection)
	}


	
}