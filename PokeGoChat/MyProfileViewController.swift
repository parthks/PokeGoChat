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
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		nameLabel.text = CurrentUser.currentUser.name
		teamName.text = CurrentUser.currentUser.team
		locationSwitch.setOn(CurrentUser.currentUser.location, animated: false)
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
