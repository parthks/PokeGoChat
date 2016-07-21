//
//  SignUpViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 13/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {

//	@IBOutlet weak var createAccLabel: UILabel!
//	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	@IBOutlet weak var autologinCheckbox: UIButton!
	@IBOutlet weak var createAccButton: UIButton!
	@IBAction func cancel(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	//
	
//	Firebase.loginWithEmail("test1@test.com", AndPassword: "test123"){ userKey in
//	print("user key: \(userKey)")
//	}
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var nameTextField: UITextField!
	
	@IBOutlet weak var teamSelection: UISegmentedControl!
	
	
	@IBAction func unwindFromUserPolicyScene(segue:UIStoryboardSegue) {}

	
	let blackTextAttributes: [NSObject : AnyObject] = [
		NSForegroundColorAttributeName: UIColor.blackColor()
	]
	
	@IBAction func segmentControl(sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			sender.tintColor = UIColor.yellowColor()
		case 1:
			sender.tintColor = UIColor.blueColor()
		case 2:
			sender.tintColor = UIColor.redColor()
		default: break
		}
		
	}
	
	@IBAction func createAccAndSignIn(sender: UIButton) {
		view.endEditing(true)
		signUp()
	}
	
	var userMadeSuccessfully: Bool = false

	func signUp(){
		guard emailTextField.text != "" else {return}
		guard passwordTextField.text != "" else {return}
		guard nameTextField.text != "" else {return}
		
//		createAccLabel.hidden = false
//		activityIndicator.startAnimating()
		
		print("signing up...")
		let email = emailTextField.text!
		let password = passwordTextField.text!
		let name = nameTextField.text!
		
		let teamName = teamSelection.titleForSegmentAtIndex(teamSelection.selectedSegmentIndex)!
		var team = ""
		
		if teamName == "Instinct" {
			team = "Yellow"
		} else if teamName == "Mystic" {
			team = "Blue"
		} else {
			team = "Red"
		}
		
		print(CurrentUser.acceptedPolicy)
		if !CurrentUser.acceptedPolicy{
			self.performSegueWithIdentifier("policy", sender: nil)
			return
		}
		
		
		Firebase.createUserWithEmail(email, AndPassword: password) { [unowned self] (userKey) in
			self.createAccButton.enabled = false
			print("back in the program")
			
			let user = User(id: userKey, name: name, team: team, location: true, latitude: nil, longitude: nil)
			CurrentUser.currentUser = user
			print("MADE USER: \(name)")
			Firebase.saveUser(user, WithKey: userKey)
			self.userMadeSuccessfully = true
			
			if self.autologinCheckbox.selected {
				let defaults = NSUserDefaults.standardUserDefaults()
				defaults.setObject(email, forKey: "email")
				defaults.setObject(password, forKey: "password")
				defaults.setObject(CurrentUser.currentUser.id, forKey: "id")
				defaults.setObject(CurrentUser.currentUser.name, forKey: "name")
				defaults.setObject(CurrentUser.currentUser.team, forKey: "team")
				defaults.setBool(CurrentUser.currentUser.location, forKey: "location")
				defaults.setObject(CurrentUser.currentUser.latitude, forKey: "latitude")
				defaults.setObject(CurrentUser.currentUser.longitude, forKey: "longitude")
			}
			
			self.performSegueWithIdentifier("madeNewUser", sender: nil)
		}
		
		print("waiting for Firebase to make user")
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		return userMadeSuccessfully
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()
		//createAccLabel.hidden = true
		nameTextField.delegate = self
		passwordTextField.delegate = self
		emailTextField.delegate = self
		
//		let backgroundImage = UIImage(named: "TriColor")
//		if let image = backgroundImage {
//			self.view.backgroundColor = UIColor(patternImage: image)
//		}
		
		let bgImage     = UIImage(named: "TriColor")
		let imageView   = UIImageView(frame: self.view.bounds)
		imageView.image = bgImage
		self.view.addSubview(imageView)
		self.view.sendSubviewToBack(imageView)
		
		teamSelection.setTitleTextAttributes(blackTextAttributes, forState: .Selected)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		
		if textField.tag == 0{
			textField.endEditing(true)
			passwordTextField.becomeFirstResponder()
		}else if textField.tag == 1{
			textField.endEditing(true)
			nameTextField.becomeFirstResponder()
		}else{
			textField.endEditing(true)
		}
		
		return true
	}

	@IBAction func policyButton(sender: AnyObject) {
		performSegueWithIdentifier("policy", sender: nil)
	}
	
	
	
	@IBAction func autologinCheckbox(sender: UIButton) {
		sender.selected = !sender.selected
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
