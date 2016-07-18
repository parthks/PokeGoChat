//
//  GeneralChatViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase

class GeneralChatViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var inputText: UITextField!
	
	
	
	var messages: [FIRDataSnapshot] = []
	var chatRoomKey: String = ""
	let maxMesLength = 140 //in characters
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moveKeyboardUp), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moveKeyboardDown), name: UIKeyboardWillHideNotification, object: nil)
		
		self.hideKeyboardWhenTappedAround()
		inputText.delegate = self
		listenForChatChanges()
		// Do any additional setup after loading the view.
	}
	
	func listenForChatChanges(){
		Firebase.listenForMessageDataOfType(dataType.GeneralMessages, WithKey: chatRoomKey){ (snapshot) in
			print("got a new message")
			self.messages.append(snapshot)
			print(self.messages)
			self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
			print("got messages into tableView")
			//self.tableView.reloadData()
		}
	}
	
	@IBAction func leaveChat(sender: UIBarButtonItem) {
		Firebase.removeUserAtCurrentGeneralRoom()
		self.dismissViewControllerAnimated(true, completion: nil)
		CurrentUser.inAChatRoom = nil
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}


//MARK: textField
extension GeneralChatViewController: UITextFieldDelegate{
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else {return true}
		let newLength = text.utf16.count + string.utf16.count - range.length
		return newLength <= maxMesLength
		
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		//guard let text = textField.text else {return true}
		guard textField.text != "" else {return true}
		let data = ["name": CurrentUser.currentUser.name, "text": textField.text!]
		print(data)
		inputText.endEditing(true)
		inputText.text = ""
		Firebase.saveMessageData(data, OfType: dataType.GeneralMessages, WithKey: chatRoomKey)
		return true
	}
	
	@IBAction func sendMessage(sender: UIButton) {
		textFieldShouldReturn(inputText)
	}
	
	
	func moveKeyboardUp(notification: NSNotification) {
		let userInfo:NSDictionary = notification.userInfo!
		let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
		let keyboardRectangle = keyboardFrame.CGRectValue()
		let keyboardHeight = keyboardRectangle.height
		self.view.frame.origin.y -= keyboardHeight
	}
	
	func moveKeyboardDown(notification: NSNotification) {
		let userInfo:NSDictionary = notification.userInfo!
		let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
		let keyboardRectangle = keyboardFrame.CGRectValue()
		let keyboardHeight = keyboardRectangle.height
		self.view.frame.origin.y += keyboardHeight
	}

	
}


//MARK: tableView
extension GeneralChatViewController: UITableViewDataSource, UITableViewDelegate{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		print("making cell...")
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
		let message = messages[indexPath.row].value as! [String: String]
		let name = message["name"]!
		let text = message["text"]!
		cell.textLabel?.text = name
		cell.detailTextLabel?.text = text
		return cell
	}
}


