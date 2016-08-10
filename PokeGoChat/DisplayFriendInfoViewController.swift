//
//  DisplayFriendInfoViewController.swift
//  Pikanect
//
//  Created by Parth Shah on 04/08/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

class DisplayFriendInfoViewController: UIViewController {

	var friend: User!			//will be provided in segue
	var friendStatus = -2		//will be provided in segue, else -2
	//KEY MAP
	//1 -> Normal friend
	//2 -> Pending friend - waiting for other person to accept
	//0 -> Invited friend - needs to accept or deny friend request
	//-1 -> Not a friend
	//-2 -> Current user
	
	@IBOutlet weak var profilePic: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var TeamName: UILabel!
	@IBOutlet weak var bio: UITextView!
	
	@IBOutlet weak var accept: UIButton!
	@IBOutlet weak var deny: UIButton!
	@IBOutlet weak var chatORPending: UIButton! //or can be Add Friend button. No chat for now
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setUPButtonsBasedOnStatus()
		populateFieldsWithFriendDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	
	
	func setUPButtonsBasedOnStatus() {
		
		print("\n\n\n\(friendStatus)")
		if friendStatus == 1 {
			accept.hidden = true
			deny.hidden = true
			chatORPending.hidden = true //No chat for now
			//chatORPending.setTitle("Chat!", forState: .Normal)
			
			
		} else if friendStatus == 2 {
			accept.hidden = true
			deny.hidden = true
			chatORPending.setTitle("Pending Friend Acceptance", forState: .Normal)
			chatORPending.enabled = false
			
		} else if friendStatus == 0 {
			accept.hidden = false
			deny.hidden = false
			chatORPending.hidden = true
			
		} else if friendStatus == -1 {
			accept.hidden = true
			deny.hidden = true
			chatORPending.setTitle("Add Friend", forState: .Normal)
			
		} else {
			friend = CurrentUser.currentUser
			accept.hidden = true
			deny.hidden = true
			chatORPending.hidden = true
			
		}
	}
	
	
	
	func populateFieldsWithFriendDetails() {
		name.text! = friend.name
		
		if friend.team == "Yellow"{
			TeamName.text! = "Instinct"
		} else if friend.team == "Blue" {
			TeamName.text! = "Mystic"
		} else {
			TeamName.text! = "Valor"
		}

		bio.text = friend.bio
		
		Network.downloadedFrom(friend.profilePicUrl) { [unowned self] image in
			guard ((UIApplication.topViewController() as? DisplayFriendInfoViewController) != nil) else {return}
			if let image = image {
				self.profilePic.image = image
			}
		}
		
		profilePic.layer.cornerRadius = 60
		profilePic.layer.masksToBounds = true
		
		self.navigationItem.title = friend.name
		let imageView = Constants.getImageViewWithName(friend.team, WithBounds: self.view.bounds)
		self.view.addSubview(imageView)
		self.view.sendSubviewToBack(imageView)
		
	}
	
	
	
	@IBAction func deny(sender: UIButton) {
		Firebase.removeFriendWithKey(friend.id)
		self.navigationController?.popViewControllerAnimated(true)
	}
	
	@IBAction func accept(sender: UIButton) {
		Firebase.acceptFriendWithKey(friend.id)
		accept.hidden = true
		deny.hidden = true
		//chatORPending.hidden = false
		//chatORPending.setTitle("Chat!", forState: .Normal)
	}
	
	@IBAction func chatORPendingORAddFriend(sender: UIButton) {
//		if sender.titleLabel?.text == "Chat!" {
//		
//			
//		} else
			if sender.titleLabel?.text == "Add Friend" {
			Firebase.addUserWithKeyAsFriendToCurrentUser(friend.id)
			sender.setTitle("Pending Friend Acceptance", forState: .Normal)
			sender.enabled = false
		}
	}
	
}





