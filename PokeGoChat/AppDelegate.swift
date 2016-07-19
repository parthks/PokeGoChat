//
//  AppDelegate.swift
//  PokeGoChat
//
//  Created by Parth Shah on 11/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		FIRApp.configure()
		
		
		let defaults = NSUserDefaults.standardUserDefaults()
		var goToLoginPage = false
		
		let email = defaults.stringForKey("email")
		let password = defaults.stringForKey("password")
		
		self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		
		
		if email != nil && password != nil{
			goToLoginPage = false
			print("not going to login page")
			
			
			let initialViewController = storyboard.instantiateViewControllerWithIdentifier("mainScreen")
			print("got controller")
			self.window?.rootViewController = initialViewController
			print("going frm here")
			self.window?.makeKeyAndVisible()
			
			Firebase.loginWithEmail(email!, AndPassword: password!) { (userKey) in
				print("finished logging in")
				Firebase.getUserDataWithKey(userKey) { (user) in
					CurrentUser.currentUser = user
					print("LOGGED IN USER: \(user.name)")
					
					goToLoginPage = true
				}
			}
			
		} else {
			print("going to login page")
			goToLoginPage = true
			let initialViewController = storyboard.instantiateViewControllerWithIdentifier("loginScreen")
			self.window?.rootViewController = initialViewController
			self.window?.makeKeyAndVisible()
		}
	
		
//		// Override point for customization after application launch.varFIRApp.configure()
//		if let inAChat = defaults.stringForKey("inAChat"){
//			if inAChat == "team"{
//				CurrentUser.currentTeamChatRoomKey = defaults.stringForKey("teamRoomKey")!
//				CurrentFirebaseLocationData.RoundedLocation = defaults.stringForKey("roundedLoc")!
//				Firebase.removeTeamRoomAtRoundedCoor()
//			}
//		}
//		
//		let initialViewController = storyboard.instantiateViewControllerWithIdentifier("loginScreen")
//		self.window?.rootViewController = initialViewController
//		//self.window?.makeKeyAndVisible()
		print("end of func")
		return goToLoginPage
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
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {

		print("quitting app...")
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

