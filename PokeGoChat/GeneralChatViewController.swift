//
//  GeneralChatViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds

class GeneralChatViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var inputText: UITextField!
	
	@IBOutlet weak var bannerView: GADBannerView!
	
	var messages: [FIRDataSnapshot] = []
	var chatRoomKey: String = ""
	let maxMesLength = 140 //in characters
	
	override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
		bannerView.adUnitID = "ca-app-pub-5358505853496020/9547069190"
		bannerView.rootViewController = self
		let request = GADRequest()
		request.testDevices = ["9ad72e72a0ec1557d7c004795a25aab9"]
		bannerView.loadRequest(request)
		
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moveKeyboardUp), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moveKeyboardDown), name: UIKeyboardWillHideNotification, object: nil)
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 140
		

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
		print("returning from textfield...")
		return true
	}
	
	@IBAction func sendMessage(sender: UIButton) {
		textFieldShouldReturn(inputText)
	}
	
	
	func moveKeyboardUp(sender: NSNotification) {
		let userInfo: [NSObject : AnyObject] = sender.userInfo!
		let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
		let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
		
		if keyboardSize.height == offset.height {
			UIView.animateWithDuration(0.1, animations: { () -> Void in
				self.view.frame.origin.y -= keyboardSize.height
			})
		} else {
			UIView.animateWithDuration(0.1, animations: { () -> Void in
				self.view.frame.origin.y += keyboardSize.height - offset.height
			})
		}
	}
	
	func moveKeyboardDown(sender: NSNotification) {
		let userInfo: [NSObject : AnyObject] = sender.userInfo!
		let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
		self.view.frame.origin.y += keyboardSize.height
	}

	
}


//MARK: tableView
extension GeneralChatViewController: UITableViewDataSource, UITableViewDelegate, ReportAndBlockUserButtonPressedDelegate {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		print("making cell...")
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DisplayMessageTableViewCell
		let message = messages[indexPath.row].value as! [String: String]
		let name = message["name"]!
		let text = message["text"]!
		let key = message["messageKey"]!
		let userID = message["userId"]!
		
		cell.userID = userID
		cell.messageKey = key
		cell.nameOfUser.text = name
		cell.message.text = text
		
		cell.delegate = self
		return cell
	}
	
	func reportUserOnCell(cell: DisplayMessageTableViewCell) {
		Firebase.displayAlertWithtitle("Reported Message", message: "The meesage has been reported to the admins")
		print("alerted with popup general")
		print(cell.message.text)
		Firebase.reportMessageWithKey(cell.messageKey, WithMessage: cell.message.text!, ByUser: cell.userID, inRoomType: "General")
	}
	
	func blockUserOnCell(cell: DisplayMessageTableViewCell) {
		if CurrentUser.currentUser.id == cell.userID {
			Firebase.displayAlertWithtitle("That's yourself!", message: "You can't block yourself!")
		} else{
			Firebase.displayAlertWithtitle("Blocked User", message: "All messages from this user have been blocked")
			Firebase.saveNewBlockedUserWithId(cell.userID)
			//tableView.reloadData()
			messages = []
			Firebase.removeGeneralMessageListener()
		}
	}

}


