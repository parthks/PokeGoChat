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
	
	var images = [String: UIImage]()
	
	var selectedCellUser:User!
	var selectedCellUserStatus: Int = -2
	
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
	let maxMesLength = 140 //in characters - a tweet!
	
	func initBanner(){
		bannerView.adUnitID = Constants.bannerAdUnitID
		bannerView.rootViewController = self
		bannerView.loadRequest(Constants.bannerAdRequest)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		initBanner()
		
		tableView.backgroundView = Constants.getImageViewWithName(Constants.image_TriColor, WithBounds: tableView.bounds)
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 140
		
		let sendBg = UIImage(named: "TricolorSendButton")
		sendButton.setBackgroundImage(sendBg, forState: .Normal)
		
		
		inputText.delegate = self
		listenForChatChanges()
		
	}

	
	
//	deinit {
//		print("removing general view controller...")
//		NSNotificationCenter.defaultCenter().removeObserver(self)
//		//Firebase.removeGeneralChatListeners()
//	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
		tableView.reloadData()
	}
	
	
	
	func listenForChatChanges(){
		print("listining for chat changes!!")
		Firebase.listenForMessageDataOfType(dataType.GeneralMessages, WithKey: chatRoomKey){ [unowned self] (message) in
			print("got a new message")
			self.messages.append(message)
			print("got messages into tableView")
			self.tableView.reloadData()
		}
	}
	
	@IBAction func leaveChat(sender: UIBarButtonItem) {
		Firebase.removeUserAtCurrentGeneralRoom()
		CurrentUser.inAChatRoom = nil
		NSNotificationCenter.defaultCenter().removeObserver(self)
		Firebase.removeGeneralChatListeners()
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	
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
			self.hideKeyboardWhenTappedAround()
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		bottomBarSpace.constant = 0
		view.setNeedsLayout()
		view.layoutIfNeeded()
		self.removeKeyboardTappingRecognizer()
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
		
		if images.indexForKey(user.id) == nil {
			Network.downloadedFrom(user.profilePicUrl) { [unowned self] image in
				guard ((UIApplication.topViewController() as? GeneralChatViewController) != nil) else {return}
				if let image = image {
					self.images[user.id] = image
					tableView.reloadData()
				}
			}
		}
		
		let text = message["text"]!
		let key = message["messageKey"]!
		let userID = message["userId"]!
		
		cell.userID = userID
		cell.messageKey = key
		cell.nameOfUser.text = user.name
		cell.message.text = text
		
		//let image = images[user.id]
		
		cell.profilePic?.layer.cornerRadius = 32
		cell.profilePic?.clipsToBounds = true
		cell.profilePic.contentMode = .ScaleAspectFill
		if images[user.id] != nil {
			cell.profilePic?.image = images[user.id]
		}
		
	
		
		cell.delegate = self
		return cell
	}
	
	
	func reportUserOnCell(cell: DisplayMessageTableViewCell) {
		AlertControllers.reportUserWithIDWithCompletionIfReported(cell.userID, messageText: cell.message.text!) {
			Firebase.reportMessageWithKey(cell.messageKey, WithMessage: cell.message.text!, ByUser: cell.userID, inRoomType: "General")
			
		}
	}
	
	
	func blockUserOnCell(cell: DisplayMessageTableViewCell) {
		if CurrentUser.currentUser.id == cell.userID {
			AlertControllers.displayAlertWithtitle("That's You!", message: "You can't block yourself!")
		} else{
			AlertControllers.blockUserWithIDWithCompletionIfBlocked(cell.userID){
				self.messages = []
				Firebase.removeGeneralChatListeners()
				self.listenForChatChanges()

			}
		}
	}
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		print("selected!!")
		let cell = tableView.cellForRowAtIndexPath(indexPath) as! DisplayMessageTableViewCell
		cell.selected = false
		
		if cell.userID == CurrentUser.currentUser.id  {
			self.selectedCellUser = CurrentUser.currentUser
			self.selectedCellUserStatus = -2
			self.performSegueWithIdentifier("showFriend", sender: nil)
		} else {
			Firebase.getStatusOfFriendWithKeyWithCurrentUser(cell.userID) { [unowned self] status in
				Firebase.getUserDataWithKey(cell.userID) { [unowned self] user in
					
					if let status = status {
						self.selectedCellUserStatus = status
					} else {
						print("NOT A FRIEND!!")
						self.selectedCellUserStatus = -1
					}
					
					
					if let user = user {
						print("got user!!")
						self.selectedCellUser = user
						
					}else {
						print("ERROR!!!")
						AlertControllers.displayErrorAlert("Could not display the selected User", error: "Could not find the user that was selected with id\(cell.userID) in general chat room \(self.chatRoomKey)", instance: "selecting cell in team chat")
						self.selectedCellUser = CurrentUser.currentUser
						self.selectedCellUserStatus = -2
					}
					
					
					self.performSegueWithIdentifier("showFriend", sender: nil)
					
				}
			}

		}
		
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		print("SEGUE!!")
		if segue.identifier == "showFriend" {
			let destination = segue.destinationViewController as! DisplayFriendInfoViewController
			
			destination.friendStatus = selectedCellUserStatus
			destination.friend = selectedCellUser
		}
	}
	

}


