//
//  Firebase.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import Firebase


enum dataType: String{
	case Users = "users"
	case GeneralMessages = "generalMessages"
	case TeamMessages = "teamMessages"
	case TeamUsers = "teamUsers"
	case TeamLocations = "teamLocations"
	case GeneralLocations = "generalLocations"
	
}

protocol FirebaseCompatible {
	func convertToFirebase() -> [String: AnyObject]
}

class Firebase{
	
	//Database reference
	static var _rootRef = FIRDatabase.database().reference()
	
	//MARK: Authentication
	static func createUserWithEmail(email: String, AndPassword password: String, takeKey: (key: String) -> Void) {
		FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
			if let error = error{
				print("ERROR CREATING USER")
				print(error.localizedDescription)
			}else if let user = user{
				takeKey(key: user.uid)
			}
		}
	}
	
	static func loginWithEmail(email: String, AndPassword password: String, takeKey: (key: String) -> Void){
		FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
			if let error = error{
				print("ERROR LOGGING IN USER")
				print(error.localizedDescription)
			}else if let user = user{
				takeKey(key: user.uid)
			}
		}
	}
	
	
	
	//MARK: Saving data
	static func saveMessageData(data: [String: String], OfType type: dataType, WithKey key: String){
		print("saving message...")
		_rootRef.child(type.rawValue).child(key).childByAutoId().setValue(data)
		print("sent message")
	}
	
	static func saveUserWithKey(userKey: String, ToTeamWithKey teamKey: String){
		print("saving user key to team")
		_rootRef.child(dataType.TeamUsers.rawValue).child(teamKey).child(userKey).setValue("1")
		//_rootRef.child(dataType.TeamUsers.rawValue).child("Num").setValue(1+TeamChatViewController.numberOfUsers)
		print("saved user key to team")
	}
	
	static func saveUser(user: User, WithKey key: String){
		print("saving user")
		_rootRef.child(dataType.Users.rawValue).child(key).setValue(user.convertToFirebase())
		print("saved user")
	}
	
	static func saveLocationOfUserWithKey(key: String, latitude: Double, longitude: Double){
		print("saving user location")
		_rootRef.child(dataType.Users.rawValue).child(key).child("latitude").setValue(latitude)
		_rootRef.child(dataType.Users.rawValue).child(key).child("longitude").setValue(longitude)
		print("saved user location")
	}
	
	static func saveNewTeamChatRoomAtLatitude(latitude: Double, AndLongitude longitude: Double) -> String{
		let locationString = getLocationString(latitude: latitude, longitude: longitude)
		print(locationString)
		let ref = _rootRef.child(dataType.TeamLocations.rawValue).child(locationString).child(CurrentUser.currentUser.team).childByAutoId()
		let key = ref.key
		ref.setValue(["latitude" : latitude, "longitude" : longitude])
		print("done saving new team chat")
		return key
	}
	
	static func saveNewGeneralChatRoomAtLatitude(latitude: Double, AndLongitude longitude: Double) -> String{
		let locationString = getLocationString(latitude: latitude, longitude: longitude)
		print(locationString)
		let ref = _rootRef.child(dataType.GeneralLocations.rawValue).child(locationString).childByAutoId()
		let key = ref.key
		ref.setValue(["latitude" : latitude, "longitude" : longitude])
		print("done saving new general chat")
		return key
	}
	
	
	//MARK: Listeners
	static func listenForMessageDataOfType(dtype: dataType, WithKey key: String, WithBlock completion: (FIRDataSnapshot) -> Void){
		print("setting up listener for \(dtype.rawValue) in room id \(key)")
		_rootRef.child(dtype.rawValue).child(key).observeEventType(.ChildAdded, withBlock: completion)
	}
	
	static func getUserDataWithKey(key: String, WithBlock completion: (User) -> Void){
		print("getting user data for key: \(key)")
		_rootRef.child(dataType.Users.rawValue).child(key).observeSingleEventOfType(.Value) { (snap, error) in
			print("got snap: \(snap)")
			let snappedUser = snap.value as! [String: AnyObject]
			let name = snappedUser["name"] as! String
			let team = snappedUser["team"] as! String
			let locationString = snappedUser["location"] as! String
			var location = true
			if locationString == "false"{
				location = false
			}
	
			let key = snappedUser["id"] as! String
			let longitude = snappedUser["longitude"] as? Double
			let latitude = snappedUser["latitude"] as? Double
			let user = User(id: key, name: name, team: team, location: location, latitude: latitude, longitude: longitude)
			print("going back to controller...")
			completion(user)
		}
	}
	
	static func getUsersFromTeamWithKey(teamKey: String, WithBlock completion: (User) -> Void) {
		print("getting users from team with key \(teamKey)")
		
		_rootRef.child(dataType.TeamUsers.rawValue).child(teamKey).observeEventType(.ChildAdded) { (snap, error) in
			
			let userKey = snap.key
			print("got userKey!")
			Firebase.getUserDataWithKey(userKey){ (user) in
				print("got another user")
				completion(user)
			}
		}
	}
	
	static func getTeamRoomsAtLatitude(latitude: Double, AndLongitude longitude: Double, WithBlock completion: [String: AnyObject]? -> Void) {
		
		let locationString = getLocationString(latitude: latitude, longitude: longitude)
		print(locationString)
		print("getting team chat rooms at all lat and long")
		_rootRef.child(dataType.TeamLocations.rawValue).child(locationString).child(CurrentUser.currentUser.team).observeSingleEventOfType(.Value) { (snap, error) in
			print("Checking if snap(team rooms at int lat and long) exists")
			if snap.exists() {
				completion(snap.value as? [String: AnyObject])
			}else{
				completion(nil)
			}
		
		}
	}
	
	
	static func getGeneralRoomsAtLatitude(latitude: Double, AndLongitude longitude: Double, WithBlock completion: [String: AnyObject]? -> Void) {
	
		let locationString = getLocationString(latitude: latitude, longitude: longitude)
		_rootRef.child(dataType.GeneralLocations.rawValue).child(locationString).observeSingleEventOfType(.Value) { (snap, error) in
			print("Checking if snap(general rooms at int lat and long) exists")
			if snap.exists() {
				completion(snap.value as? [String: AnyObject])
			}else{
				completion(nil)
			}
			
		}
	}
	
}

private func getLocationString(latitude latitude: Double, longitude: Double) -> String{
	let roundedLat = Double(round(latitude * 100) / 100)
	let roundedLong = Double(round(longitude * 100) / 100)
	let decimalLong = Int((abs(roundedLong) % 1) * 100)
	let decimalLat = Int((abs(roundedLat) % 1) * 100)
	
	let locationString = "\(Int(roundedLat))-\(decimalLat) \(Int(roundedLong))-\(decimalLong) "
	return locationString
}

