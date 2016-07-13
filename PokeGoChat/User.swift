//
//  User.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation

struct User: FirebaseCompatible {
	
	var name: String
	var picture: NSDate
	let team: String
	var bio: String
	var location: Bool
	
	func convertToFirebase() -> [String : AnyObject] {
		return [:]
	}
}