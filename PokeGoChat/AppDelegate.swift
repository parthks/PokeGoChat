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
import Fabric
import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	struct NetInfo {
		let ip: String
		let netmask: String
	}
	
	// Get the local ip addresses used by this node
	func getIFAddresses() -> [NetInfo] {
		var addresses = [NetInfo]()
		
		// Get list of all interfaces on the local machine:
		var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
		if getifaddrs(&ifaddr) == 0 {
			var ptr = ifaddr
			while(ptr != nil) {
				let flags = Int32(ptr.memory.ifa_flags)
				var addr = ptr.memory.ifa_addr.memory
				
				// Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
				if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
					if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
						
						// Convert interface address to a human readable string:
						var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
						if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
							nil, socklen_t(0), NI_NUMERICHOST) == 0) {
							if let address = String.fromCString(hostname) {
								
								var net = ptr.memory.ifa_netmask.memory
								var netmaskName = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
								getnameinfo(&net, socklen_t(net.sa_len), &netmaskName, socklen_t(netmaskName.count),
                    nil, socklen_t(0), NI_NUMERICHOST) == 0
								if let netmask = String.fromCString(netmaskName) {
									addresses.append(NetInfo(ip: address, netmask: netmask))
								}
							}
						}
					}
				}
				ptr = ptr.memory.ifa_next
			
			}
//			// For each interface ...
//			for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
//							}
			freeifaddrs(ifaddr)
		}
		return addresses
	}
	
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		FIRApp.configure()
		Fabric.with([Crashlytics.self])
		
		UINavigationBar.appearance().tintColor = UIColor.blackColor()
		UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.blackColor()]
		
		print(getIFAddresses().last!.ip)
		print(getIFAddresses().last!.netmask)

		//need to store for security reasons
		CurrentUser.netmask = getIFAddresses().last!.netmask
		CurrentUser.ip = getIFAddresses().last!.ip
		
//		var public_ip = try! String(contentsOfURL: NSURL(string: "https://api.ipify.org/")!)
//		print(public_ip)
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

