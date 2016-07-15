//
//  GetChatRoomKey.swift
//  PokeGoChat
//
//  Created by Parth Shah on 14/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation

struct GetChatRoomKey {
	
	
	
	static func returnTeamRoomKey() -> String {
		CurrentUser.currentTeamChatRoomKey = "random" //for mapsViewCon to retrive users in team
		Firebase.saveUserWithKey(CurrentUser.currentUser.id, ToTeamWithKey: "random") //for location of all team members
		return "random"
	}
	
	static func returnGeneralRoomKey() -> String {
		return "random"
	}
}