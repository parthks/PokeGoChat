//
//  User.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation

class CurrentUser {
	static func currentUser() -> User{
		return User(name: "Parth", picture: nil, team: "Yellow", bio: "Hello World", location: true)
	}
	
	
}

struct User: FirebaseCompatible {
	
	var name: String
	var picture: NSData?
	let team: String
	var bio: String
	var location: Bool
	
	func convertToFirebase() -> [String : AnyObject] {
		return [:]
	}
}