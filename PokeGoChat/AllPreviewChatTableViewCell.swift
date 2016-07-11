//
//  AllPreviewChatTableViewCell.swift
//  PokeGoChat
//
//  Created by Parth Shah on 11/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

class AllPreviewChatTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	@IBOutlet weak var profilePic: UIImageView!
	@IBOutlet weak var chatName: UILabel!
	@IBOutlet weak var lastMessage: UILabel!
	@IBOutlet weak var name: UILabel!

}
