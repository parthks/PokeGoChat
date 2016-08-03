//
//  AppInfoViewController.swift
//  Pikanect
//
//  Created by Parth Shah on 20/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase

class AppInfo: UIViewController {

	@IBOutlet weak var textView: UITextView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		UIBarButtonItem.appearance().tintColor = UIColor.blackColor()
		let bgImage     = UIImage(named: CurrentUser.currentUser.team);
		let imageView   = UIImageView(frame: self.view.bounds);
		imageView.image = bgImage
		self.view.addSubview(imageView)
		self.view.sendSubviewToBack(imageView)
		
		textView.contentOffset = CGPointMake(0, -220)
		textView.contentOffset = CGPointMake(0, -textView.contentSize.height)
		
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
	@IBOutlet weak var textView: UITextView!
	override func viewDidLoad() {
		super.viewDidLoad()
		textView.contentOffset = CGPointMake(0, -220)
		textView.contentOffset = CGPointMake(0, -textView.contentSize.height)

		
		// Do any additional setup after loading the view.
	}
	@IBAction func close(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBAction func agreeButton(sender: AnyObject) {
		//NSUserDefaults.standardUserDefaults().setBool(true, forKey: "madeAcoount")
		
		CurrentUser.currentUser = User(id: "\(CurrentUser.currentID!)", name: "Default name", team: "\(CurrentUser.currentTeam)", location: false, latitude: nil, longitude: nil, profilePicUrl: nil)
		Firebase.saveUser(CurrentUser.currentUser, WithKey: CurrentUser.currentID!)
		
		self.performSegueWithIdentifier("agreedPolicy", sender: nil)
		AlertControllers.displayAlertWithtitle("Please change your name", message: "A \"Default name\" has been given to you, please go to \"Profile\" and change your name")
		

			
		
		
	}
	
	
}

