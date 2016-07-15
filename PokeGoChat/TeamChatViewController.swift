//
//  TeamChatViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase

class TeamChatViewController: UIViewController {

	//static var numberOfUsers = 0
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var inputText: UITextField!
	
	var messages: [FIRDataSnapshot] = []
	var chatRoomKey: String = ""
	
	let maxMesLength = 140 //in characters
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = "Team \(CurrentUser.currentUser.team)"
		self.hideKeyboardWhenTappedAround()
		inputText.delegate = self
		listenForChatChanges()
        // Do any additional setup after loading the view.
    }
	
	func listenForChatChanges(){
		Firebase.listenForMessageDataOfType(dataType.TeamMessages, WithKey: chatRoomKey){ (snapshot) in
			print("got a new message")
			self.messages.append(snapshot)
			print(self.messages)
			self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
			print("got messages into tableView")
			//self.tableView.reloadData()
		}
	}
	
	@IBAction func leaveChat(sender: UIBarButtonItem) {
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
extension TeamChatViewController: UITextFieldDelegate{
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
		Firebase.saveMessageData(data, OfType: dataType.TeamMessages, WithKey: chatRoomKey)
		return true
	}
	
	@IBAction func sendMessage(sender: UIButton) {
		textFieldShouldReturn(inputText)
	}
	
	func textFieldDidBeginEditing(textField: UITextField) {
		//inputText.frame.origin.y -= 500
		self.view.frame.origin.y -= 250

		
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		//inputText.frame.origin.y += 500
		self.view.frame.origin.y += 250
		
	}
	
}


//MARK: tableView
extension TeamChatViewController: UITableViewDataSource, UITableViewDelegate{
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


