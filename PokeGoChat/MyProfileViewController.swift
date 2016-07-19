//
//  MyProfileViewController.swift
//  test
//
//  Created by Parth Shah on 11/07/16.
//  Copyright © 2016 testFirebase. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {
	
	@IBOutlet weak var nameLabel: UITextField!
	@IBOutlet weak var locationSwitch: UISwitch!
	@IBOutlet weak var teamName: UILabel!
	@IBOutlet weak var profilePic: UIImageView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
		
	}
	
	
	@IBAction func signOut(sender: UIButton) {
		NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
		self.view.window!.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		self.view.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("loginScreen")


	}
	
	
	
	@IBAction func donateButton(sender: AnyObject) {
		UIApplication.sharedApplication().openURL(NSURL(string:"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=S6KB5Y78T7RQ4&lc=US&item_name=Pokemon%20Chat%20Apple%20App&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted")!)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		nameLabel.text = CurrentUser.currentUser.name
		teamName.text = CurrentUser.currentUser.team
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
		CurrentUser.currentUser.name = nameLabel.text ?? "Default Name"
		CurrentUser.currentUser.location = locationSwitch.on
		Firebase.saveUser(CurrentUser.currentUser, WithKey: CurrentUser.currentUser.id)
		self.navigationController?.popViewControllerAnimated(true)
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


extension UIViewController {
	func hideKeyboardWhenTappedAround() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
		view.addGestureRecognizer(tap)
	}
	
	func dismissKeyboard() {
		view.endEditing(true)
	}
}
