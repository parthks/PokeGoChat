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
			if error != nil{
				print("ERROR CREATING USER")
				print(error!)
			}else if let user = user{
				takeKey(key: user.uid)
			}
		}
	}
	
	static func loginWithEmail(email: String, AndPassword password: String, takeKey: (key: String) -> Void){
		FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
			if error != nil{
				print("ERROR LOGGING IN USER")
				print(error!)
			}else if let user = user{
				takeKey(key: user.uid)
			}
		}
	}
	
	
	
	//MARK: Saving data
	static func saveData(data: FirebaseCompatible, OfType type: dataType){
		
	}
	
	
	//MARK: Listeners
	static func listenForNewMessagesWithBlock(completion: (FIRDataSnapshot) -> Void){
		print("setting up listener for messages")
		_rootRef.child("messages").observeEventType(.ChildAdded, withBlock: completion)
	}
	
	
	
}
