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
				print(error)
			}else if let user = user{
				takeKey(key: user.uid)
			}
		}
	}
	
	static func loginWithEmail(email: String, AndPassword password: String, takeKey: (key: String) -> Void){
		FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
			if let error = error{
				print("ERROR LOGGING IN USER")
				print(error)
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
	
//	static func saveNewUser(user: User){
//		print("saving new user...")
//		_rootRef.child(dataType.Users.rawValue).childByAutoId().setValue(user.convertToFirebase())
//		print("saved user")
//	}
	
	static func saveUser(user: User, WithKey key: String){
		print("saving user")
		_rootRef.child(dataType.Users.rawValue).child(key).setValue(user.convertToFirebase())
		print("saved user")
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
			let snappedUser = snap.value as! [String: String]
			let name = snappedUser["name"]
			let team = snappedUser["team"]
			let locationString = snappedUser["location"]
			var location = true
			if locationString == "false"{
				location = false
			}
	
			let key = snappedUser["key"]
			
			let user = User(id: key!, name: name!, team: team!, location: location)
			print("going back to controller...")
			completion(user)
		}
	}
	
}
