//
//  MyProfileViewController.swift
//  test
//
//  Created by Parth Shah on 11/07/16.
//  Copyright © 2016 testFirebase. All rights reserved.
//

import UIKit
import Firebase

class MyProfileViewController: UIViewController {
	
	
	@IBOutlet weak var nameLabel: UITextField!
	@IBOutlet weak var locationSwitch: UISwitch!
	@IBOutlet weak var teamName: UILabel!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var profilePic: UIButton!
	
	var picker: PhotoTakingHelper!
	var setImage = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
		
//		getImageWithCompletion() { [unowned self] image in
//			self.profilePic.setImage(image, forState: .Normal)
//		}
//
//		do {
//			Firebase.getProfilePicWithUid(CurrentUser.currentID!) { [unowned self] image in
//				if let image = image {
//					self.profilePic.setImage(image, forState: .Normal)
//				}
//			}
//		}
		
		print(CurrentUser.currentUser.profilePicUrl)
		Network.downloadedFrom(CurrentUser.currentUser.profilePicUrl) { image in
			if let image = image {
				//self.profilePic.selected = false
				self.profilePic.setImage(image, forState: .Normal)
				self.profilePic.setImage(image, forState: .Selected)
				//self.profilePic.setNeedsDisplay()
				print(image)
				print("HAVE PUT THE IMAGE")
			}
		
		
			
		}
		
		profilePic.layer.cornerRadius = 60
		profilePic.clipsToBounds = true
		saveButton.tintColor = UIColor(red: 25/256, green: 161/256, blue: 57/256, alpha: 1)

	}
	
//	func getImageWithCompletion(completion: (image: UIImage?)-> Void) {
//		if let pic = CurrentUser.imageUrl{
//			if let data = NSData(contentsOfURL: pic) {
//				let image = UIImage(data: data)
//				completion(image: image!)
//			}
//		}
//	}
	
	
	@IBAction func signOut(sender: UIButton) {
		try! FIRAuth.auth()!.signOut()
		NSUserDefaults.standardUserDefaults().setBool(false, forKey: "autoLogin")
		print("SIGN OUT WORKS")
		
		
		let defaults = NSUserDefaults.standardUserDefaults()
		let doneAppRating = defaults.boolForKey("doneAppRating")
		let quitApp = defaults.boolForKey("quitApp")
		
		defaults.removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
		self.view.window!.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
		
		defaults.setBool(doneAppRating, forKey: "doneAppRating")
		defaults.setBool(quitApp, forKey: "quitApp")
		
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.view.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("loginScreen")
		


	}
	
	
	
	@IBAction func donateButton(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string:"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=VCU7DYL9KQGDQ&lc=US&item_name=Pikanect%20App&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted")!)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		nameLabel.text = CurrentUser.currentUser.name ?? "Default name"

		if CurrentUser.currentUser.team == "Yellow"{
			teamName.text = "Instinct"
		} else if CurrentUser.currentUser.team == "Blue" {
			teamName.text = "Mystic"
		} else {
			teamName.text = "Valor"
		}
		
		locationSwitch.setOn(CurrentUser.currentUser.location, animated: false)
		
		let bgImage     = UIImage(named: CurrentUser.currentUser.team);
		let imageView   = UIImageView(frame: self.view.bounds);
		imageView.image = bgImage
		self.view.addSubview(imageView)
		self.view.sendSubviewToBack(imageView)
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	@IBAction func save(sender: UIBarButtonItem) {
		guard nameLabel.text != "" else {
			AlertControllers.displayAlertWithtitle("Name field empty", message: "Please enter a name for yourself")
			return
		}
		
		CurrentUser.currentUser.name = nameLabel.text!
		CurrentUser.currentUser.location = locationSwitch.on
		
		if setImage {
			Firebase.saveProfilePic(profilePic.imageView!.image!)
			NSCache().setObject(profilePic.imageView!.image!, forKey: CurrentUser.currentID!)
		}
		
		Firebase.saveUser(CurrentUser.currentUser, WithKey: CurrentUser.currentUser.id)
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	
	
	@IBAction func setImage(sender: UIButton) {
		picker = PhotoTakingHelper(viewController: self) { [unowned self] image in
			print("got image")
			print(image)
			self.profilePic.setImage(image, forState: .Normal)
			self.profilePic.setImage(image, forState: .Selected)
			self.setImage = true
		}
	}
	

}


