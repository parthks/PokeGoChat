//
//  GetChatRoomKey.swift
//  PokeGoChat
//
//  Created by Parth Shah on 14/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import MapKit

class GetChatRoomKey {
	
	let userLat: Double
	let userLong: Double
	
	var roomKey: String = ""
	var inATeamRoom = false
	var inAGenRoom = false
	
	let userLocation: CLLocation
	
	init() {
		userLat = CurrentUser.currentUser.latitude!
		userLong = CurrentUser.currentUser.longitude!
		
		userLocation = CLLocation(latitude: userLat, longitude: userLong)
	}
	
	//var lat = 37.787359000000002
	//var long = -122.408227
	
	
	func returnTeamRoomKeyWithBlock(completion: (key: String) -> Void){
		
		print("Getting all team chat rooms at rounded lat and long")
		Firebase.getTeamRoomsAtLatitude(userLat, AndLongitude: userLong) { (teams) in
			if let teams = teams{
				
				//var tempLocToGetMin = [String: AnyObject]()
				print("Indexing through all team chat room to find close chat room")
				for (roomKey, loc) in teams{
					let latNlong = loc as! [String: Double]
					let location = CLLocation(latitude: latNlong["latitude"]!, longitude: latNlong["longitude"]!)
					if self.userLocation.distanceFromLocation(location) < 20{
						self.roomKey = roomKey
						self.inATeamRoom = true
//						tempLocToGetMin["roomkey"] = roomKey
//						tempLocToGetMin["location"] = latNlong
					}
				}
				
				
				
				if !self.inATeamRoom {
					print("MAKING A TEAM CHAT ROOM")
					self.roomKey = Firebase.saveNewTeamChatRoomAtLatitude(self.userLat, AndLongitude: self.userLong)
				}
			
			
				
				
			} else {
				print("MAKING A CHAT ROOM IN A NEW LAT AND LONG")
				self.roomKey = Firebase.saveNewTeamChatRoomAtLatitude(self.userLat, AndLongitude: self.userLong)
				
			}
			
			CurrentUser.currentTeamChatRoomKey = self.roomKey
			Firebase.saveUserWithKey(CurrentUser.currentUser.id, ToTeamWithKey: self.roomKey) //for location of all team members
			CurrentUser.inAChatRoom = "team"
			completion(key: self.roomKey)
		}

	}
	

	
	
	func returnGeneralRoomKeyWithBlock(completion: (key: String) -> Void){
		
		print("Getting all general chat rooms at int lat and long")
		Firebase.getGeneralRoomsAtLatitude(userLat, AndLongitude: userLong) { (generalRooms) in
			if let generalRooms = generalRooms {
				
				
				print("Indexing through all team chat room to find close chat room")
				for (roomKey, loc) in generalRooms{
					let latNlong = loc as! [String: Double]
					let location = CLLocation(latitude: latNlong["latitude"]!, longitude: latNlong["longitude"]!)
					print("\n\n\n")
					print(self.userLocation.distanceFromLocation(location))
					print("\n\n\n")
					if self.userLocation.distanceFromLocation(location) < 20{
						self.roomKey = roomKey
						self.inAGenRoom = true
						break
					}
				}
				
				if !self.inAGenRoom {
					print("MAKING A GENERAL CHAT ROOM")
					self.roomKey = Firebase.saveNewGeneralChatRoomAtLatitude(self.userLat, AndLongitude: self.userLong)
				}
				
				
				
				
			} else {
				print("MAKING A GENERAL CHAT ROOM IN A NEW LAT AND LONG")
				self.roomKey = Firebase.saveNewGeneralChatRoomAtLatitude(self.userLat, AndLongitude: self.userLong)
				
			}
			
			CurrentUser.currentGeneralChatRoomKey = self.roomKey
			Firebase.saveUserWithKey(CurrentUser.currentUser.id, ToGeneralWithKey: self.roomKey)
			print(self.roomKey)
			CurrentUser.inAChatRoom = "general"
			completion(key: self.roomKey)
		}
		
	}
	

	
	
	
}