//
//  SIgnInViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 13/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase

class SIgnInViewController: UIViewController {

	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	@IBAction func signInButtonTapped(sender: UIButton) {
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
	
	

	@IBAction func createAccButtontapped(sender: UIButton) {
		
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.hideKeyboardWhenTappedAround()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
