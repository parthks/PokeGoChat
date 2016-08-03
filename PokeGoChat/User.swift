//
//  User.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import UIKit //need UIColor

class CurrentUser {
	
	static var currentUser: User!
	static var currentTeamChatRoomKey: String!
	static var currentGeneralChatRoomKey: String!
	static var inAChatRoom: String? = nil //nil, "team", "general"
	static var acceptedPolicy = false
	static var imageUrl: NSURL?
	
	static var currentUserName: String!
	static var currentTeam: String!
	static var currentID: String?
	
	static var ip: String!
	static var netmask: String!
	
	static var findUsersRadius = 1000.0 //in meters (double)
	
}

struct loginDetailsForSIgnUp {
	static var emailID: String!
	static var password: String!
}


class CurrentFirebaseLocationData {
	static var RoundedLocation: String!
}

struct User: FirebaseCompatible {
	
	let id: String
	var name: String
	var team: String
	var location: Bool
	var latitude: Double?
	var longitude: Double?
	var profilePicUrl: String?
	
	func getTeamUIColor() -> UIColor{
		if self.team == "Red"{
			return UIColor.redColor()
		}else if self.team == "Blue"{
			return UIColor.blueColor()
		}else{
			return UIColor.yellowColor()
		}
	}
	
	func convertToFirebase() -> [String : AnyObject] {
		var firebaseUserData = [String: AnyObject]()
		firebaseUserData["id"] = id
		firebaseUserData["name"] = name
		firebaseUserData["team"] = team
		var locationString = "false"
		if location{
			locationString = "true"
		}
		firebaseUserData["location"] = locationString
		firebaseUserData["longitude"] = longitude ?? "nil"
		firebaseUserData["latitude"] = latitude ?? "nil"
		firebaseUserData["profilePicUrl"] = profilePicUrl
		
		return firebaseUserData
	}
}