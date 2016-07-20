//
//  DisplayMessageTableViewCell.swift
//  PokeGoChat
//
//  Created by Parth Shah on 18/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

protocol ReportAndBlockUserButtonPressedDelegate {
	func reportUserOnCell(cell: DisplayMessageTableViewCell)
	func blockUserOnCell(cell: DisplayMessageTableViewCell)
}

class DisplayMessageTableViewCell: UITableViewCell {

	@IBOutlet weak var nameOfUser: UILabel!
	@IBOutlet weak var message: UILabel!
	@IBOutlet weak var reportButton: UIButton!
	
	var delegate: ReportAndBlockUserButtonPressedDelegate!
	var messageKey: String = ""
	var userID: String = ""
	var reported: String = "false"
	
	@IBAction func reportButton(sender: AnyObject) {
		print("report message")
		delegate.reportUserOnCell(self)
		//reportButton.enabled = false
	}
	
	
	@IBAction func blockButon(sender: AnyObject) {
		delegate.blockUserOnCell(self)
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
