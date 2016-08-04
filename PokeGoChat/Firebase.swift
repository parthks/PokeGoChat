//
//  Firebase.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import UIKit //for alert controllers
import Firebase


enum dataType: String{
	case Users = "users"
	case GeneralMessages = "generalMessages"
	case TeamMessages = "teamMessages"
	case TeamUsers = "teamUsers"
	case GeneralUsers = "generalUsers"
	case TeamLocations = "teamLocations"
	case GeneralLocations = "generalLocations"
	case ReportedMessages = "reportedMessages"
	case BlockedUsers = "userFollowedByBlockedUsers"
	case Friends = "friendsOf"
	case ProfilePic = "profilePic" //in storage
	
}

protocol FirebaseCompatible {
	func convertToFirebase() -> [String: AnyObject]
}

class Firebase {
	
	//Database and Storage reference
	static var databaseRef = FIRDatabase.database().reference()
	static var storageRef = FIRStorage.storage().reference()
	
	//MARK: Authentication
	static func createUserWithEmail(email: String, AndPassword password: String, takeKey: (key: String?, error: NSError?) -> Void) {
		FIRAuth.auth()?.createUserWithEmail(email, password: password) { (user, error) in
			if let error = error{
				print("ERROR CREATING USER")
				AlertControllers.displayErrorAlert(error.localizedDescription, error: error.description, instance: "createUserWithEmail")
				takeKey(key: nil, error: error)
			}else if let user = user{
				takeKey(key: user.uid, error: nil)
			}
		}
	}
	
	static func loginWithEmail(email: String, AndPassword password: String, takeKey: (key: String?, error: NSError?) -> Void){
		FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
			if let error = error{
				print("ERROR LOGGING IN USER")
				AlertControllers.displayErrorAlert(error.localizedDescription, error: error.description, instance: "loginWithEmail")
				takeKey(key: nil, error: error)
			}else if let user = user{
				takeKey(key: user.uid, error: nil
				)
			}
		}
	}
	
	//MARK: Error saving
	
	static func saveError(error: String, DuringInstance instance: String){
		print("saving error to firebase")
		databaseRef.child("ERRORS").childByAutoId().setValue(
			[
			"userID": CurrentUser.currentID ?? "Not logged in yet",
			"instance": instance,
			"error": error
			]
		)
	}
	
	//MARK: Saving data
	static func saveMessageData(data: [String: String], OfType type: dataType, WithKey key: String){
		print("saving message...\(type)")
		//key is the room key
		var fdata = data
		fdata["userId"] = CurrentUser.currentUser.id
		let ref = databaseRef.child(type.rawValue).child(key).childByAutoId()
		let key = ref.key

		fdata["messageKey"] = key
		ref.setValue(fdata)
		
		let timestamp: AnyObject = FIRServerValue.timestamp()
		let public_ip = Network.getPublicIpAddress() ?? "nil"
		let localNetworkInfo = Network.getLocalAddress()
		//archiving message
		let archivedMessage: [String: AnyObject] = [
			"messageKey" : key,
			"userID" : CurrentUser.currentUser.id,
			"roomType" : type.rawValue,
			"timestamp": timestamp,
			"public IP": public_ip,
			"local IP": localNetworkInfo?.ip ?? "nil",
			"netmask": localNetworkInfo?.netmask ?? "nil"
		]
		databaseRef.child("archivedMessages").childByAutoId().setValue(archivedMessage)
		
		
		print("sent message")
	}
	
	static func saveUserWithKey(userKey: String, ToTeamWithKey teamKey: String){
		print("saving user key to team")
		databaseRef.child(dataType.TeamUsers.rawValue).child(teamKey).child(userKey).setValue("1")
		//databaseRef.child(dataType.TeamUsers.rawValue).child("Num").setValue(1+TeamChatViewController.numberOfUsers)
		print("saved user key to team")
	}
	
	static func saveUserWithKey(userKey: String, ToGeneralWithKey generalKey: String){
		print("saving user key to general")
		databaseRef.child(dataType.GeneralUsers.rawValue).child(generalKey).child(userKey).setValue("1")
		//databaseRef.child(dataType.TeamUsers.rawValue).child("Num").setValue(1+TeamChatViewController.numberOfUsers)
		print("saved user key to general")
	}
	
	static func saveUser(user: User, WithKey key: String){
		//print("saving user")
		databaseRef.child(dataType.Users.rawValue).child(key).setValue(user.convertToFirebase())

		//print("saved user")
	}
	
	static func saveLocationOfUserWithKey(key: String, latitude: Double, longitude: Double){
		//print("saving user location")
		databaseRef.child(dataType.Users.rawValue).child(key).child("latitude").setValue(latitude)
		databaseRef.child(dataType.Users.rawValue).child(key).child("longitude").setValue(longitude)
		//print("saved user location")
	}
	
	static func saveNewTeamChatRoomAtLatitude(latitude: Double, AndLongitude longitude: Double) -> String{
		let locationString = getLocationString(latitude: latitude, longitude: longitude)
		//print(locationString)
		let ref = databaseRef.child(dataType.TeamLocations.rawValue).child(locationString).child(CurrentUser.currentUser.team).childByAutoId()
		let key = ref.key
		ref.setValue(["latitude" : latitude, "longitude" : longitude])
		//print("done saving new team chat")
		return key
	}
	
	static func saveNewGeneralChatRoomAtLatitude(latitude: Double, AndLongitude longitude: Double) -> String{
		let locationString = getLocationString(latitude: latitude, longitude: longitude)
		print(locationString)
		let ref = databaseRef.child(dataType.GeneralLocations.rawValue).child(locationString).childByAutoId()
		let key = ref.key
		ref.setValue(["latitude" : latitude, "longitude" : longitude])
		//print("done saving new general chat")
		return key
	}
	
	
	//MARK: Listeners
	static func listenForMessageDataOfType(dtype: dataType, WithKey key: String, WithBlock completion: (Message) -> Void){
		Firebase.getAllBlockedUsersForCurrentUserWithBlock() { (blockedUsers) in
			
			//print("setting up listener for \(dtype.rawValue) in room id \(key)")
			databaseRef.child(dtype.rawValue).child(key).queryLimitedToLast(50).observeEventType(.ChildAdded){
				(snap, _) in
				
				print("got into message listiner...")
				
				if snap.exists(){
					print("\n\n\n\nGOT SNAP!!!..")
					print(snap.value)
					let data = snap.value as! [String: String]
					let userID = data["userId"]!
					Firebase.getUserDataWithKey(userID) { user in
						print("LISTINING FOR MESSAGES")
						guard (user != nil) else {
							AlertControllers.displayErrorAlert("Could not find a user! If this error occurs repeatedly please report it", error: "didnt find user with id \(userID) while listening for messages", instance: "getUserDataWithKey(\(userID))")
							return
						}
						
						if !blockedUsers.contains(userID) {
							print("\n\n\n\nSNAP AFTER GETTING USER!!!..")
							print(snap.value)
							let message = Message(user: user!, message: snap)
							completion(message)
						}else{
							return
						}
					}
					
				}
				
			}

		
		}
	}
	
	static func getUserDataWithKey(key: String, WithBlock completion: (User)? -> Void){
		print("getting user data for key: \(key)")
		databaseRef.child(dataType.Users.rawValue).child(key).observeSingleEventOfType(.Value) { (snap, prevChildKey) in
			
			if !snap.exists() {
				completion(nil)
				print("NEW USER!")
				return
			}
			
			print("user has value")
			print(snap.value)
			print("got user")
			let snappedUser = snap.value as! [String: AnyObject]
			let name = snappedUser["name"] as! String
			let team = snappedUser["team"] as! String
			let bio = snappedUser["bio"] as? String ?? "Bio..."
			let locationString = snappedUser["location"] as! String
			
			var location = true
			if locationString == "false"{
				location = false
			}
			
			let key = snappedUser["id"] as! String
			let longitude = snappedUser["longitude"] as? Double
			let latitude = snappedUser["latitude"] as? Double
			let profilePicUrl = snappedUser["profilePicUrl"] as? String
			
			let user = User(id: key, name: name, team: team, bio: bio, location: location, latitude: latitude, longitude: longitude, profilePicUrl: profilePicUrl)
			
			print("going back to controller...")
			completion(user)
			}
		
	}

	
	static func getUsersFromTeamWithKey(teamKey: String, WithBlock completion: (User) -> Void) {
		//print("getting users from team with key \(teamKey)")
		
		databaseRef.child(dataType.TeamUsers.rawValue).child(teamKey).observeEventType(.ChildAdded, withBlock: { snap in
	
			let userKey = snap.key
			//print("got userKey!")
			Firebase.getUserDataWithKey(userKey){ (user) in
				//print("got another user")
				completion(user!)
			}
		
		})
	}
	
	static func getTeamRoomsAtLatitude(latitude: Double, AndLongitude longitude: Double, WithBlock completion: [String: AnyObject]? -> Void) {
		
		let locationString = getLocationString(latitude: latitude, longitude: longitude)
		print(locationString)
		//print("getting team chat rooms at all lat and long")
		databaseRef.child(dataType.TeamLocations.rawValue).child(locationString).child(CurrentUser.currentUser.team).observeSingleEventOfType(.Value) { (snap, prevChildKey) in
			
	
			//print("Checking if snap(team rooms at int lat and long) exists")
			if snap.exists() {
				completion(snap.value as? [String: AnyObject])
			}else{
				completion(nil)
			}

			
			
			
		}
	}
	
	
	static func getGeneralRoomsAtLatitude(latitude: Double, AndLongitude longitude: Double, WithBlock completion: [String: AnyObject]? -> Void) {
	
		let locationString = getLocationString(latitude: latitude, longitude: longitude)
		databaseRef.child(dataType.GeneralLocations.rawValue).child(locationString).observeSingleEventOfType(.Value) { (snap, prevChildKey) in
			
	
			print("Checking if snap(general rooms at int lat and long) exists")
			if snap.exists() {
				completion(snap.value as? [String: AnyObject])
			}else{
				completion(nil)
			}
			
		}
	}
	
	
	//MARK: Removers
	
	static func removeTeamRoomAtRoundedCoor() {
		print("removing team room")
		databaseRef.child(dataType.TeamLocations.rawValue).child(CurrentFirebaseLocationData.RoundedLocation).child(CurrentUser.currentUser.team).child(CurrentUser.currentTeamChatRoomKey).removeValue()
		databaseRef.child(dataType.TeamMessages.rawValue).child(CurrentUser.currentTeamChatRoomKey).removeValue()
		print("removed team room")
	}
	
	static func removeUserAtCurrentTeamRoom() {
		databaseRef.child(dataType.TeamUsers.rawValue).child(CurrentUser.currentTeamChatRoomKey).child(CurrentUser.currentUser.id).removeValue()
		print("deleted user")
		databaseRef.child(dataType.TeamUsers.rawValue).child(CurrentUser.currentTeamChatRoomKey).observeSingleEventOfType(.Value) { (snap, prevChildKey) in
			
			print("Checking if snap(team rooms at int lat and long) exists")
			if !snap.exists() {
				Firebase.removeTeamRoomAtRoundedCoor()
			}
		}
	}
	
	static func removeUserAtCurrentGeneralRoom() {
		databaseRef.child(dataType.GeneralUsers.rawValue).child(CurrentUser.currentGeneralChatRoomKey).child(CurrentUser.currentUser.id).removeValue()
		databaseRef.child(dataType.GeneralUsers.rawValue).child(CurrentUser.currentGeneralChatRoomKey).observeSingleEventOfType(.Value) { (snap, prevChildKey) in
			
			print("Checking if snap(general rooms at int lat and long) exists")
			if !snap.exists() {
				Firebase.removeGeneralRoomAtRoundedCoor()
			}
		}
	}
	
	static func removeGeneralRoomAtRoundedCoor() {
		print("removing general room")
		databaseRef.child(dataType.GeneralLocations.rawValue).child(CurrentFirebaseLocationData.RoundedLocation).child(CurrentUser.currentGeneralChatRoomKey).removeValue()
		databaseRef.child(dataType.GeneralMessages.rawValue).child(CurrentUser.currentGeneralChatRoomKey).removeValue()
		print("removed general room")
	}
	
	
	//MARK: Remove Observers
	static func removeTeamListeners() {
		databaseRef.child(dataType.TeamMessages.rawValue).child(CurrentUser.currentTeamChatRoomKey).removeAllObservers()
		databaseRef.child(dataType.TeamUsers.rawValue).child(CurrentUser.currentTeamChatRoomKey).removeAllObservers()
	}
	
	static func removeGeneralChatListeners() {
		databaseRef.child(dataType.GeneralMessages.rawValue).child(CurrentUser.currentGeneralChatRoomKey).removeAllObservers()
	}
	
	
	
	static func removeListeningForBlockedUsers(){
		databaseRef.child(dataType.BlockedUsers.rawValue).child(CurrentUser.currentUser.id).removeAllObservers()

	}
	
	
	
	
	//MARK: Report message
	static func reportMessageWithKey(messageKey: String, WithMessage message:String, ByUser userid: String, inRoomType roomType: String) {
		
		databaseRef.child(dataType.ReportedMessages.rawValue).child(messageKey).observeSingleEventOfType(.Value) { (snap, prevChildKey) in
			if !snap.exists(){
				//make new reported message!
				var reportedMessage = [String: String]()
				reportedMessage["message"] = message
				reportedMessage["messageKey"] = messageKey
				reportedMessage["roomType"] = roomType
				reportedMessage["numberOfTimesReported"] = "1"
				reportedMessage["userID"] = userid
				if roomType == "Team"{
					reportedMessage["roomKey"] = CurrentUser.currentTeamChatRoomKey
				}else{
					reportedMessage["roomKey"] = CurrentUser.currentGeneralChatRoomKey
				}
				
				databaseRef.child(dataType.ReportedMessages.rawValue).child(messageKey).setValue(reportedMessage)

			} else{
				var reportedMessage = snap.value as! [String: String]
				let num = Int(reportedMessage["numberOfTimesReported"]!)!
				reportedMessage["numberOfTimesReported"] = "\(num+1)"
				databaseRef.child(dataType.ReportedMessages.rawValue).child(messageKey).setValue(reportedMessage)
			}
		}
		
	}
	
	
	
	
	
	
	//MARK: Blocked Users
	static func saveNewBlockedUserWithId(blockedUserid: String) {
		databaseRef.child(dataType.BlockedUsers.rawValue).child(CurrentUser.currentUser.id).child(blockedUserid).setValue("1")
	}
	
	static func removeBlockedUserWithId(blockedUserid: String) {
		databaseRef.child(dataType.BlockedUsers.rawValue).child(CurrentUser.currentUser.id).child(blockedUserid).removeValue()
	}
	
	static func getAllBlockedUsersForCurrentUserWithBlock(completion: [String] -> Void) {
		
		var handle:UInt = 0
		let ref = databaseRef.child(dataType.BlockedUsers.rawValue).child(CurrentUser.currentUser.id)
		handle = ref.observeEventType(.Value) { (snap, prevChildKey) in
			let blockedUsers: [String]
			if snap.exists() {
				let data = snap.value as! [String: String]
				blockedUsers = Array(data.keys)
			}else{
				blockedUsers = []
			}
			
			ref.removeObserverWithHandle(handle)
			completion(blockedUsers)
			
			
		}
	}
	
	
	//MARK: Friends
//	static func addUserWithKeyAsFriendToCurrentUser(key: String) {
//		databaseRef.child(dataType.Friends.rawValue).child(CurrentUser.currentUser.id).setValue([key: "1"])
//	}
//	
//	static func getAllFrindsKeyOfCurrnetUserWithBlock(completion: [String] -> Void) {
//		databaseRef.child(dataType.Friends.rawValue).child(CurrentUser.currentUser.id).observeSingleEventOfType(.Value) { snap, prevChildKey in
//			var friends = [String]()
//			guard snap.exists() else {completion(friends); return}
//			
//			for dictValue in snap.value as! [String: String] {
//				let key = dictValue.0
//				print(key)
//				friends.append(key)
//			}
//			
//			completion(friends)
//		}
//	}
	

	//MARK: Storage
	
	//MARK: Get and set profile pic
	static func saveProfilePic(image: UIImage) {
		storageRef.child(dataType.ProfilePic.rawValue).child("\(CurrentUser.currentID!)").putData(UIImageJPEGRepresentation(image, 0.5)!, metadata: nil) { metadata, error in
			if error != nil {
				print("ERROR!!")
			} else {
				print("SAVED THE URL")
				CurrentUser.imageUrl = metadata?.downloadURL()
				CurrentUser.currentUser.profilePicUrl = CurrentUser.imageUrl?.absoluteString
				Firebase.saveUser(CurrentUser.currentUser, WithKey: CurrentUser.currentID!)
				
			}
		}
		
//		storageRef.child(dataType.ProfilePic.rawValue).child("\(CurrentUser.currentID!).jpg").downloadURLWithCompletion { url, error in
//			if error == nil {
//				CurrentUser.imageUrl = url
//			} else {
//				print("ERROR")
//				print(error!.localizedDescription)
//			}
//		}
	}
	
//	static func getProfilePicWithUid(id: String, completion: UIImage? -> Void) {
//		
//		if let pic = CurrentUser.imageUrl{
//			if let data = NSData(contentsOfURL: pic) {
//				let image = UIImage(data: data)
//				completion(image!)
//				
//			} else { print("ERROR\n\n\(pic)"); completion(nil) }
//			
//		} else { print("error"); completion(nil) }
//		
//	
//	}
}








func getLocationString(latitude latitude: Double, longitude: Double) -> String{
	let roundedLat = Double(round(latitude * 100) / 100)
	let roundedLong = Double(round(longitude * 100) / 100)
	let decimalLong = Int((abs(roundedLong) % 1) * 100)
	let decimalLat = Int((abs(roundedLat) % 1) * 100)
	
	let locationString = "\(Int(roundedLat))-\(decimalLat) \(Int(roundedLong))-\(decimalLong)"
	CurrentFirebaseLocationData.RoundedLocation = locationString
	return locationString
}


