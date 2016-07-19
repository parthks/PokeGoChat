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
		let team = teamSelection.titleForSegmentAtIndex(teamSelection.selectedSegmentIndex)!
		
		Firebase.createUserWithEmail(email, AndPassword: password) { (userKey) in
			self.createAccButton.enabled = false
			print("back in the program")
			
			let user = User(id: userKey, name: name, team: team, location: true, latitude: nil, longitude: nil)
			CurrentUser.currentUser = user
			print("MADE USER: \(name)")
			Firebase.saveUser(user, WithKey: userKey)
			self.userMadeSuccessfully = true
			self.performSegueWithIdentifier("madeNewuser", sender: nil)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
