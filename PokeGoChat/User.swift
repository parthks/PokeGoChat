//
//  User.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation

class CurrentUser {
	
	static var currentUser: User!

}

struct User: FirebaseCompatible {
	
	let id: String
	var name: String
	let team: String
	var location: Bool
	
	func convertToFirebase() -> [String : AnyObject] {
		var firebaseUserData = [String: String]()
		firebaseUserData["id"] = id
		firebaseUserData["name"] = name
		firebaseUserData["team"] = team
		var locationString = "false"
		if location{
			locationString = "true"
		}
		firebaseUserData["location"] = locationString
		
		return firebaseUserData
	}
}