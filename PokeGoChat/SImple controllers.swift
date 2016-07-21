//
//  AppInfoViewController.swift
//  Pikanect
//
//  Created by Parth Shah on 20/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

class AppInfo: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBAction func mail(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string : "mailto:pikanect@gmail.com")!)
	}

	@IBAction func facebook(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string : "https://facebook.com/pikanect/")!)
	}
	
	@IBAction func twitter(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string : "https://twitter.com/PikanectApp/")!)
	}
}


class UserPolicy: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	var acceptedPolicy = false
	@IBAction func close(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func agreeButton(sender: AnyObject) {
		CurrentUser.acceptedPolicy = true
		print(CurrentUser.acceptedPolicy)
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
}
