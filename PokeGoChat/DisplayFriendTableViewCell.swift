//
//  DisplayFriendTableViewCell.swift
//  PokeGoChat
//
//  Created by Parth Shah on 11/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

class DisplayFriendTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		switch self.reuseIdentifier! {
		case "RequestingFriendCell":
			addFriendButton.hidden = true
			acceptFriendButton.hidden = false
			declineFriendButton.hidden = false
			
		case "AddFriendCell":
			addFriendButton.hidden = false
			acceptFriendButton.hidden = true
			declineFriendButton.hidden = true
			
		default:
			addFriendButton.hidden = true
			acceptFriendButton.hidden = true
			declineFriendButton.hidden = true
		}
		
	
    }
	
	

	@IBOutlet weak var profilePic: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var teamName: UILabel!
	@IBOutlet weak var playerDescription: UILabel!

	@IBOutlet weak var addFriendButton: UIButton!
	
	@IBOutlet weak var acceptFriendButton: UIButton!
	@IBOutlet weak var declineFriendButton: UIButton!
	
	
}
