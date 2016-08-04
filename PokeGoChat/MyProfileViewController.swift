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
	
	
	@IBOutlet weak var nameField: UITextField!
	@IBOutlet weak var locationSwitch: UISwitch!
	@IBOutlet weak var teamName: UILabel!
	@IBOutlet weak var saveButton: UIBarButtonItem!
	@IBOutlet weak var profilePic: UIButton!
	@IBOutlet weak var bioTextView: UITextView!
	@IBOutlet weak var scrollView: UIScrollView!
	@IBOutlet weak var myBlockedUsers: UIButton!
	@IBOutlet weak var bottomOfBio: NSLayoutConstraint!
	
	let maxNameSize = 30
	let maxBioSize = 300
	var picker: PhotoTakingHelper!
	var setImage = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		print(self.view.bounds)
		
		self.hideKeyboardWhenTappedAround()
		nameField.delegate = self
		bioTextView.delegate = self
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil)

		
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
	

	func keyboardWillShow(notification:NSNotification){
		
		var userInfo = notification.userInfo!
		var keyboardFrame:CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
		//print(keyboardFrame)
		keyboardFrame = self.view.convertRect(keyboardFrame, fromView: nil)
		//print(keyboardFrame)
		//var contentInset:UIEdgeInsets = self.scrollView.contentInset
		//contentInset.bottom = keyboardFrame.size.height + 120
		//self.scrollView.contentInset = contentInset
		//print(self.myBlockedUsers.frame)
		
		//print(self.bioTextView.frame)
		//print(keyboardFrame)
		//bottomOfBio.constant = keyboardFrame.height
		
		//view.setNeedsLayout()
		//view.layoutIfNeeded()
		print(self.scrollView.bounds)
		print(self.scrollView.frame)
		
		//print(self.scrollView.frame)
		let visibleRect = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.contentOffset.x + self.scrollView.bounds.size.width, self.scrollView.contentOffset.y + self.scrollView.bounds.size.height)
		print(visibleRect)
		//print(visibleRect.minY)
		//print(visibleRect.maxY)
		
		let fixedVisibleHeightOfScrollView = self.scrollView.contentOffset.y + self.scrollView.bounds.size.height
		//print(fixedVisibleHeightOfScrollView)
		let currentScrollViewHeight = self.scrollView.frame.height
		//print(currentScrollViewHeight)
		let heightDifference = Double(350 - currentScrollViewHeight)
		//print(heightDifference)
		//print(heightDifference - Double(self.scrollView.contentOffset.y))
		let keyboardAtHeight = Double(keyboardFrame.minY)
		let relativeBottomOfTextView = Double(self.scrollView.frame.maxY) - 20.0 - 35.0 - 20.0
		
		let bottomOfTextView = relativeBottomOfTextView + heightDifference - Double(self.scrollView.contentOffset.y) //when scroll view is at bottom
		
		//print(bottomOfTextView)
		//print(keyboardAtHeight)
		let offset = CGFloat(bottomOfTextView - keyboardAtHeight)
		//print(self.view.bounds)
		//print(self.view.frame)
		
		//let bioFrame = self.bioTextView.frame
		//self.scrollView.scrollRectToVisible(CGRectMake(self.bioTextView.frame.maxX, self.bioTextView.frame.maxY, self.bioTextView.bounds.width, 300), animated: true)
		
//		print(self.scrollView.frame.maxY) //542
		
		//542-20-35-20 = 467 -> bottom of text view
		//so 467 - 451(the keyboard start height) = 16 - GOLDEN NUMBER!!
		
//		print(self.bioTextView.frame.minY)
//		print(self.bioTextView.frame.maxY)//255
//		
		
//		let offset = self.scrollView.frame.maxY - self.bioTextView.frame.maxY - keyboardFrame.size.height
//		print(offset)
		self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.bounds.origin.y+offset+8), animated: true)
		//self.bioTextView.contentInset = contentInset
	}
	
	func keyboardWillHide(notification:NSNotification){
		
//		bottomOfBio.constant = 0
//		view.setNeedsLayout()
//		view.layoutIfNeeded()
//		
//		//let contentInset:UIEdgeInsets = UIEdgeInsetsZero
//		//self.scrollView.contentInset = contentInset
//		self.scrollView.setContentOffset(CGPointMake(0, self.scrollView.bounds.origin.y-50), animated: true)
//		//self.bioTextView.contentInset = contentInset
	}
	
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	
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
		nameField.text = CurrentUser.currentUser.name ?? "Default name"
		bioTextView.text = CurrentUser.currentUser.bio ?? "Bio..."
		
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
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		scrollView.flashScrollIndicators()
	}
	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	@IBAction func save(sender: UIBarButtonItem) {
		guard nameField.text != "" else {
			AlertControllers.displayAlertWithtitle("Name field empty", message: "Please enter a name for yourself")
			return
		}
		
		CurrentUser.currentUser.name = nameField.text!
		CurrentUser.currentUser.location = locationSwitch.on
		
		if bioTextView.text != "" {
			CurrentUser.currentUser.bio = bioTextView.text!
		} else {
			CurrentUser.currentUser.bio = "Bio..."
		}
		
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

extension MyProfileViewController: UITextViewDelegate {
	func textViewDidChange(textView: UITextView) {
		let range = NSMakeRange(textView.text.characters.count - 1, 1);
		textView.scrollRangeToVisible(range)
	}
}

extension MyProfileViewController: UITextFieldDelegate {
	
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		let oldCharCount = textField.text!.characters.count
		let newCharCount = string.characters.count
		print(oldCharCount + newCharCount)
		if oldCharCount + newCharCount > maxNameSize {
			return false
		}
		return true
	}
	
}


