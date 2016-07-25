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
	
	@IBOutlet weak var bottomBarSpace: NSLayoutConstraint!
	
	@IBOutlet weak var sendButton: UIButton!
	var messages: [Message] = [] {
		didSet {
			messages.sortInPlace(orderMessages)
		}
	}
	
	func orderMessages(one: Message, two: Message) -> Bool{
		if one.messageSnap.key < two.messageSnap.key {
			return true
		} else {
			return false
		}
	}
	
	
	var chatRoomKey: String = ""
	let maxMesLength = 140 //in characters
	
	
	deinit {
		print("removing general view controller...")
		NSNotificationCenter.defaultCenter().removeObserver(self)
		//Firebase.removeGeneralChatListeners()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		Firebase.removeGeneralChatListeners()
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		print("KEY BELOW")
		print(chatRoomKey)
		print("KEY ABOVE")
		//let bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
		bannerView.adUnitID = "ca-app-pub-5358505853496020/9547069190"
		bannerView.rootViewController = self
		let request = GADRequest()
//		request.testDevices = ["9ad72e72a0ec1557d7c004795a25aab9"]
		bannerView.loadRequest(request)
		
		let bgImage     = UIImage(named: "TriColor")
		let imageView   = UIImageView(frame: tableView.bounds)
		imageView.image = bgImage
		tableView.backgroundView = imageView
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 140
		
		let sendBg = UIImage(named: "TricolorSendButton")
		sendButton.setBackgroundImage(sendBg, forState: .Normal)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appEnteredBackground), name: UIApplicationWillResignActiveNotification, object: nil)
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appHasComeBackFromBackground), name: UIApplicationDidBecomeActiveNotification, object: nil)
		
		self.hideKeyboardWhenTappedAround()
		inputText.delegate = self
		listenForChatChanges()
		// Do any additional setup after loading the view.
	}
	
	
	func listenForChatChanges(){
		print("listining for chat changes!!")
		Firebase.listenForMessageDataOfType(dataType.GeneralMessages, WithKey: chatRoomKey){ [unowned self] (message) in
			print("got a new message")
			self.messages.append(message)
			//print(self.messages)
			//print("PRINTED MESSAGES!")
			//print(self.messages)
			//self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
			print("got messages into tableView")
			self.tableView.reloadData()
		}
	}
	
	@IBAction func leaveChat(sender: UIBarButtonItem) {
		Firebase.removeUserAtCurrentGeneralRoom()
		CurrentUser.inAChatRoom = nil
		Firebase.removeGeneralChatListeners()
		self.dismissViewControllerAnimated(true, completion: nil)
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
		let data = ["text": textField.text!]
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
	
	
	func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
			bottomBarSpace.constant = keyboardFrame.height
			view.setNeedsLayout()
			view.layoutIfNeeded()
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		bottomBarSpace.constant = 0
		view.setNeedsLayout()
		view.layoutIfNeeded()
	}
	
}


//MARK: tableView
extension GeneralChatViewController: UITableViewDataSource, UITableViewDelegate, ChatCellDelegate {
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		print("making cell...")
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! DisplayMessageTableViewCell
		let message = messages[indexPath.row].messageSnap.value as! [String: String]
		let user = messages[indexPath.row].user
		let text = message["text"]!
		let key = message["messageKey"]!
		let userID = message["userId"]!
		
		cell.userID = userID
		cell.messageKey = key
		cell.nameOfUser.text = user.name
		cell.message.text = text
		
		cell.delegate = self
		return cell
	}
	
	func reportUserOnCell(cell: DisplayMessageTableViewCell) {
		
		let alert = UIAlertController(title: "Are you sure you want to report this message?", message: cell.message.text, preferredStyle: .Alert)
		let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
		
		let reportButton = UIAlertAction(title: "Report!", style: .Destructive) { (alert) in
			Firebase.displayAlertWithtitle("Reported Message Confirmation", message: "The meesage has been reported to the admins")
			Firebase.reportMessageWithKey(cell.messageKey, WithMessage: cell.message.text!, ByUser: cell.userID, inRoomType: "General")
			//self.dismissViewControllerAnimated(true, completion: nil)
		}
		
		alert.addAction(cancelButton)
		alert.addAction(reportButton)
		
		presentViewController(alert, animated: true, completion: nil)
	}
	
	
	func blockUserOnCell(cell: DisplayMessageTableViewCell) {
		if CurrentUser.currentUser.id == cell.userID {
			Firebase.displayAlertWithtitle("That's You!", message: "You can't block yourself!")
		} else{
			
			let alert = UIAlertController(title: "Are you sure you want to block this user?", message: "All messages from this user will be hidden", preferredStyle: .Alert)
			let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
			
			let blockButton = UIAlertAction(title: "Block!", style: .Destructive) { [unowned self] (alert) in
				Firebase.displayAlertWithtitle("Successfully Blocked User", message: "All messages from this user have been blocked")
				Firebase.saveNewBlockedUserWithId(cell.userID)
				print("blocked user")
				//messages.removeAll()
				self.messages = []
				Firebase.removeGeneralChatListeners()
				self.listenForChatChanges()
				//self.dismissViewControllerAnimated(true, completion: nil)
			}
			
			alert.addAction(cancelButton)
			alert.addAction(blockButton)
			
			presentViewController(alert, animated: true, completion: nil)
			
		}
		
		
	}
	

}


