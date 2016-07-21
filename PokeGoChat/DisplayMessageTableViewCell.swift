//
//  DisplayMessageTableViewCell.swift
//  PokeGoChat
//
//  Created by Parth Shah on 18/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

protocol ChatCellDelegate: class{
	func reportUserOnCell(cell: DisplayMessageTableViewCell)
	func blockUserOnCell(cell: DisplayMessageTableViewCell)
	//func addFriendOnWithKey(friendKey: String)
}

class DisplayMessageTableViewCell: UITableViewCell {

	@IBOutlet weak var nameOfUser: UILabel!
	@IBOutlet weak var message: UILabel!
	@IBOutlet weak var reportButton: UIButton!
	@IBOutlet weak var addFriend: UIButton!
	
	weak var delegate: ChatCellDelegate!
	var messageKey: String = ""
	var userID: String = ""
	//var reported: String = "false"
	
	@IBAction func reportButton(sender: AnyObject) {
		print("report message")
		delegate.reportUserOnCell(self)
		//reportButton.enabled = false
	}
	
	
	@IBAction func blockButon(sender: AnyObject) {
		delegate.blockUserOnCell(self)
	}
	
//	@IBAction func addFriend(sender: AnyObject) {
//		Firebase.addUserWithKeyAsFriendToCurrentUser(userID)
//		Firebase.displayAlertWithtitle("Congratulations", message: "You have made a new friend!")
//	}
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
