//
//  SignUpViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 13/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {


	@IBOutlet weak var yellowTeam: UIButton!
	@IBOutlet weak var blueTeam: UIButton!
	@IBOutlet weak var redTeam: UIButton!
	
	@IBOutlet weak var createAccount: UIButton!
	
	var imageView = UIImageView()
	
	var image: UIImage! {
		didSet {
			imageView.removeFromSuperview()
			imageView.image = image
			self.view.addSubview(imageView)
			self.view.sendSubviewToBack(imageView)
		}
	}
	
	@IBAction func cancel(sender: UIButton) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func goToPolicy(sender: AnyObject) {
		if !(redTeam.selected || yellowTeam.selected || blueTeam.selected) {
			Firebase.displayAlertWithtitle("Please select a Team", message: "Please click the team you wish to join to conect with teammates")
		}
		self.performSegueWithIdentifier("policy", sender: nil)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		imageView.frame = self.view.bounds
		
		image = UIImage(named: "TriColor")
		
		
//		let redImg     = UIImage(named: "Red")
//		let redImageView   = UIImageView(frame: self.view.bounds)
//		redImageView.image = redImg
//		
//		let blueImg     = UIImage(named: "Blue")
//		let blueImageView   = UIImageView(frame: self.view.bounds)
//		blueImageView.image = blueImg
//		
//		let yellowImg     = UIImage(named: "Yellow")
//		let yellowImageView   = UIImageView(frame: self.view.bounds)
//		yellowImageView.image = yellowImg
		
		
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
		@IBAction func policyButton(sender: AnyObject) {
		performSegueWithIdentifier("policy", sender: nil)
	}
	
	
	
	
	@IBAction func redTeamButtonPressed(sender: UIButton) {
		sender.selected = true
		sender.titleLabel?.textColor = UIColor.blackColor()
		blueTeam.selected = false
		blueTeam.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
		yellowTeam.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
		yellowTeam.selected = false
		sender.backgroundColor = UIColor.redColor()
		image = UIImage(named: "Red")
		CurrentUser.currentTeam = "Red"
		
	}
	
	@IBAction func blueTeamButtonPressed(sender: UIButton) {
		sender.selected = true
		sender.titleLabel?.textColor = UIColor.blackColor()
		redTeam.selected = false
		yellowTeam.selected = false
		redTeam.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
		yellowTeam.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
		sender.backgroundColor = UIColor.blueColor()
		image = UIImage(named: "Blue")
		CurrentUser.currentTeam = "Blue"
		
	}
	
	@IBAction func yellowTeamButtonPressed(sender: UIButton) {
		sender.selected = true
		sender.titleLabel?.textColor = UIColor.blackColor()
		blueTeam.selected = false
		redTeam.selected = false
		blueTeam.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
		redTeam.backgroundColor = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 1)
		sender.backgroundColor = UIColor.yellowColor()
		image = UIImage(named: "Yellow")
		CurrentUser.currentTeam = "Yellow"
	}
	
}
