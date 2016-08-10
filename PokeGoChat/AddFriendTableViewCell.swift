//
//  AddFriendTableViewCell.swift
//  Pikanect
//
//  Created by Parth Shah on 09/08/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

class AddFriendTableViewCell: UITableViewCell {

	
	@IBOutlet weak var profilePic: UIImageView!
	@IBOutlet weak var name: UILabel!
	@IBOutlet weak var addFriendButton: UIButton!
	
	@IBAction func addFriend(sender: UIButton) {
	}
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
