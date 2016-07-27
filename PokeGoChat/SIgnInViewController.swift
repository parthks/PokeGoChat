//
//  SIgnInViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 13/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

class SIgnInViewController: UIViewController, UITextFieldDelegate {

	
	@IBOutlet weak var signInActivityLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	@IBOutlet weak var checkboxButton: UIButton!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var createAccountButton: UIButton!
	
	//@IBOutlet weak var signInLabel: UILabel!
	//@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	@IBAction func signInButtonTapped(sender: UIButton) {
		print("sign in button pressed")
		signInButtonPressed()
		view.endEditing(true)
		signIn()
	}
	
	var userSignedInSucessfully: Bool = false
	
	@IBAction func createAccButtonPressed(sender: UIButton) {
		print("create acc button pressed")
		signInButtonPressed()
		
		guard emailTextField.text != "" else {doneSigningIn();return}
		guard passwordTextField.text != "" else {doneSigningIn();return}

		loginDetailsForSIgnUp.emailID = emailTextField.text
		loginDetailsForSIgnUp.password = passwordTextField.text
		
		signUp()
	}
	
	 func signInButtonPressed() {
		signInActivityLabel.hidden = false
		activityIndicator.hidden = false
		activityIndicator.startAnimating()
		signInButton.enabled = false
		createAccountButton.enabled = false
		//googleSignButton.userInteractionEnabled = false
	}
	
	 func doneSigningIn() {
		signInActivityLabel.hidden = true
		activityIndicator.hidden = true
		activityIndicator.stopAnimating()
		signInButton.enabled = true
		createAccountButton.enabled = true
		//googleSignButton.userInteractionEnabled = true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboardWhenTappedAround()
		let bgImage		= UIImage(named: "TriColor")
		let imageView   = UIImageView(frame: self.view.bounds)
		imageView.image = bgImage
		self.view.addSubview(imageView)
		self.view.sendSubviewToBack(imageView)
	
	}
	
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		doneSigningIn()
		let defaults = NSUserDefaults.standardUserDefaults()
		if defaults.boolForKey("autoLogin"){
			signInButtonPressed()
			emailTextField.text = defaults.stringForKey("email")
			passwordTextField.text = defaults.stringForKey("password")
			signIn()
			
		}
		NSUserDefaults.standardUserDefaults().setBool(true, forKey: "autoLogin")
	}
	
	
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField.tag == 0{
			textField.endEditing(true)
			passwordTextField.becomeFirstResponder()
		}else {
			textField.endEditing(true)
			signIn()
		}
		
		return true
	}
	
	@IBAction func autoLoginCheckbox(sender: UIButton) {
		sender.selected = !sender.selected
		NSUserDefaults.standardUserDefaults().setBool(sender.selected, forKey: "autoLogin")
	}
	
	func signUp(){
		Firebase.createUserWithEmail(loginDetailsForSIgnUp.emailID, AndPassword: loginDetailsForSIgnUp.password) { [unowned self] key, error in
				if let _ = error {
					self.doneSigningIn()
					return
				}
			
				if self.checkboxButton.selected {
					let defaults = NSUserDefaults.standardUserDefaults()
					defaults.setObject(loginDetailsForSIgnUp.emailID, forKey: "email")
					defaults.setObject(loginDetailsForSIgnUp.password, forKey: "password")
				}
				CurrentUser.currentID = key!
				Firebase.storeIpNetmaskOfCurrentUser()
				self.performSegueWithIdentifier("teamSelect", sender: nil)

		}
	
	}
	
	func signIn(){
		guard emailTextField.text != "" else {doneSigningIn();return}
		guard passwordTextField.text != "" else {doneSigningIn();return}
	
		
		print("signing in...")
		let email = emailTextField.text!
		let password = passwordTextField.text!
		
		Firebase.loginWithEmail(email, AndPassword: password) { [unowned self] (userKey, error) in
			if let _ = error {
				self.doneSigningIn()
				return
			}
			self.signInButton.enabled = false
			print("finished logging in")
			CurrentUser.currentID = userKey
			Firebase.getUserDataWithKey(userKey!) { (user) in
				
				if user == nil {
					self.performSegueWithIdentifier("teamSelect", sender: nil)
					return
				}
				
				CurrentUser.currentUser = user
				print(user)
				self.userSignedInSucessfully = true
				
				if self.checkboxButton.selected {
					let defaults = NSUserDefaults.standardUserDefaults()
					defaults.setObject(email, forKey: "email")
					defaults.setObject(password, forKey: "password")
				}
				
				self.performSegueWithIdentifier("loggedInUser", sender: nil)
				
			}
			
		}
		
		print("waiting for Firebase to log in user")
		
	}
	
	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "goingToSignUp"{
			return true
		}else{
			return userSignedInSucessfully
		}
		
	}
	
	@IBAction func forgotPassButtonTapped(sender: UIButton) {
		let prompt = UIAlertController.init(title: "Password Reset", message: "Enter Email:", preferredStyle: UIAlertControllerStyle.Alert)
		let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.Default) { (action) in
			let userInput = prompt.textFields![0].text
			if (userInput!.isEmpty) {
				return
			}
			FIRAuth.auth()?.sendPasswordResetWithEmail(userInput!) { (error) in
				if let error = error {
					print(error.localizedDescription)
					return
				}
			}
		}
		prompt.addTextFieldWithConfigurationHandler(nil)
		prompt.addAction(okAction)
		presentViewController(prompt, animated: true, completion: nil);
	}
	


}


	