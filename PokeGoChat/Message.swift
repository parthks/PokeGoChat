//
//  Message.swift
//  Pikanect
//
//  Created by Parth Shah on 25/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import Firebase

class Message {
	var user: User
	var messageSnap: FIRDataSnapshot
	
	init(user: User, message: FIRDataSnapshot) {
		self.user = user
		self.messageSnap = message
	}
}