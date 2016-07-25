//
//  AppDelegate.swift
//  PokeGoChat
//
//  Created by Parth Shah on 11/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(application: UIApplication,
	                 openURL url: NSURL, options: [String: AnyObject]) -> Bool {
		return GIDSignIn.sharedInstance().handleURL(url,
		                                            sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
		                                            annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
	}
	
	func application(application: UIApplication,
	                 openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		var _: [String: AnyObject] = [UIApplicationOpenURLOptionsSourceApplicationKey: sourceApplication!,
		                              UIApplicationOpenURLOptionsAnnotationKey: annotation]
		return GIDSignIn.sharedInstance().handleURL(url,
		                                            sourceApplication: sourceApplication,
		                                            annotation: annotation)
	}

		
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		FIRApp.configure()
		UINavigationBar.appearance().tintColor = UIColor.blackColor()
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
		

		//FIRDatabase.database().persistenceEnabled = true

		

//		let defaults = NSUserDefaults.standardUserDefaults()
//		let userID = defaults.stringForKey("id")
//		
//		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
//		let storyboard = UIStoryboard(name: "Main", bundle: nil)
//		
//		
//		if userID != nil { //If user id is stored then everything is
//			print("going to main screen")
//			let initialViewController = storyboard.instantiateViewControllerWithIdentifier("mainScreen")
//			CurrentUser.currentUser = User(id: defaults.stringForKey("id")!,
//			                               name: defaults.stringForKey("name")!,
//			                               team: defaults.stringForKey("team")!,
//			                               location: defaults.boolForKey("location"),
//			                               latitude: nil,
//			                               longitude: nil)
//			
//			
//			self.window?.rootViewController = initialViewController
//			self.window?.makeKeyAndVisible()
//			
//		} else {
//			print("going to login page")
//			let initialViewController = storyboard.instantiateViewControllerWithIdentifier("loginScreen")
//			self.window?.rootViewController = initialViewController
//			self.window?.makeKeyAndVisible()
//		}
	
	
		return true
	}

	func applicationWillResignActive(application: UIApplication) {

		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
		
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
//		if self.window?.rootViewController is TeamChatViewController {
//			NSNotificationCenter.defaultCenter().addObserver(TeamChatViewController(), selector: #selector(TeamChatViewController.moveKeyboardUp), name: UIKeyboardWillShowNotification, object: nil)
//			NSNotificationCenter.defaultCenter().addObserver(TeamChatViewController(), selector: #selector(TeamChatViewController.moveKeyboardDown), name: UIKeyboardWillHideNotification, object: nil)
//		}
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {

		print("quitting app...")
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "quitApp")
		
		if CurrentUser.inAChatRoom != nil {
			if CurrentUser.inAChatRoom == "team"{
				Firebase.removeUserAtCurrentTeamRoom()
			} else {
				Firebase.removeUserAtCurrentGeneralRoom()
			}
			
		}
		
		//does not remove the team/general room in locations and messages when the user is the last 
		//perosn in the room and force quits the app! - closure block to check if users left is not
		//executed! - will just run script to clean up database!
		
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

extension UIApplication {
	class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
		if let nav = base as? UINavigationController {
			return topViewController(nav.visibleViewController)
		}
		if let tab = base as? UITabBarController {
			if let selected = tab.selectedViewController {
				return topViewController(selected)
			}
		}
		if let presented = base?.presentedViewController {
			return topViewController(presented)
		}
		return base
	}
}

