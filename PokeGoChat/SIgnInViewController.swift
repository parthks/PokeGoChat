//
//  SIgnInViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 13/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase

class SIgnInViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

	@IBOutlet weak var googleSignButton: GIDSignInButton!
	
	@IBOutlet weak var signInActivityLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
//	func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
//	            withError error: NSError!) {
//		if let error = error {
//			print(error.localizedDescription)
//			return
//		}
//		
//		print("GOOGLE SIGN IN HAPPENING")
//		let authentication = user.authentication
//		let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
//                                                               accessToken: authentication.accessToken)
//		FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
//			
//		}
//	}
//
	
	 func signInButtonPressed() {
		signInActivityLabel.hidden = false
		activityIndicator.hidden = false
		activityIndicator.startAnimating()
		googleSignButton.userInteractionEnabled = false
	}
	
	 func doneSigningIn() {
		signInActivityLabel.hidden = true
		activityIndicator.hidden = true
		activityIndicator.stopAnimating()
		googleSignButton.userInteractionEnabled = true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
		GIDSignIn.sharedInstance().uiDelegate = self
		GIDSignIn.sharedInstance().delegate = self

		
		let bgImage		= UIImage(named: "TriColor")
		let imageView   = UIImageView(frame: self.view.bounds)
		imageView.image = bgImage
		self.view.addSubview(imageView)
		self.view.sendSubviewToBack(imageView)
	
	}
	
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		doneSigningIn()
		
		if NSUserDefaults.standardUserDefaults().boolForKey("autoLogin"){
			signInButtonPressed()
			GIDSignIn.sharedInstance().signIn()
		}
	}
	
	func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
	            withError error: NSError!) {
		
		if let _ = error {
			doneSigningIn()
			return
		}
		signInButtonPressed()
		CurrentUser.currentUserName = user.profile.name
		CurrentUser.imageUrl = user.profile.imageURLWithDimension(50)
		
		let authentication = user.authentication
		let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                               accessToken: authentication.accessToken)
		print("Signing in to Firebase")
		FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
			print("GOT USER USING GOOGLE")
			if let error = error  {
				print("\n\n\nERROR\n\n\n")
				print(error)
				//Firebase.displayErrorAlert("Please check your internet connection",error: error, instance: "signing in")
				return
			}
			print(user)
			CurrentUser.currentID = user!.uid
			Firebase.getUserDataWithKey((user?.uid)!) { [unowned self] user in
				self.doneSigningIn()
				if let user = user {
					print(user)
					NSUserDefaults.standardUserDefaults().setBool(true, forKey: "autoLogin")
					CurrentUser.currentUser = user
					UIApplication.topViewController()?.performSegueWithIdentifier("signedIn", sender: nil)
				} else {
					print("new user...")
					UIApplication.topViewController()?.performSegueWithIdentifier("signUp", sender: nil)
				}
			}
			// ...
		}
	}
	
	func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
	            withError error: NSError!) {
		print("\n\nDISCONNECTED FROM THE APP!!\n\n\n")
		// Perform any operations when the user disconnects from app here.
		// ...
	}
	
	


}
