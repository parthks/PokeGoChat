//
//  TeamChatViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 12/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import GoogleMobileAds

class TeamChatViewController: UIViewController {

	//static var numberOfUsers = 0
	@IBOutlet weak var bannerView: GADBannerView!
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var inputText: UITextField!
	@IBOutlet weak var myLocationSwitch: UISwitch!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var bottomBarSpaceToAds: NSLayoutConstraint!

	var locationManager = CLLocationManager()
	var users = [User]() {
		didSet{
			if (users.count > 0) {
				if (users.last!.location && users.last!.id != CurrentUser.currentUser.id) {
					//self.labelBelowMap.text = "Displaying location of \(self.users.count) teammates"
					self.placePinAtLongitude(users.last!.longitude, latitude: users.last!.latitude, userName: (users.last!.name))
				}
			}
		}

	}
	
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		print("removing team chat timer...")
		//locationManager.stopUpdatingLocation()
		NSNotificationCenter.defaultCenter().removeObserver(self)
		timer.invalidate()
		Firebase.removeTeamListeners()
	}
	
//	deinit {
//		print("removing team chat...")
//		NSNotificationCenter.defaultCenter().removeObserver(self)
//		timer.invalidate()
//		Firebase.removeTeamListeners()
//	}
	
	
	
	
	@IBAction func locationChanged(sender: UISwitch) {
		CurrentUser.currentUser.location = myLocationSwitch.on
		Firebase.saveUser(CurrentUser.currentUser, WithKey: CurrentUser.currentUser.id)
		print("UPDATED LOCATION")
	}
	
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
	var timer: NSTimer = NSTimer()
	let maxMesLength = 140 //in characters - a tweet!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		print("\n\nDOING THE VIEW DID LOAD IN TEAM CHAT\n\n")
		bannerView.adUnitID = "ca-app-pub-5358505853496020/9547069190"
		bannerView.rootViewController = self
		let request = GADRequest()
		//request.testDevices = ["9ad72e72a0ec1557d7c004795a25aab9"]
		bannerView.loadRequest(request)

		
		print("entered TeamChatViewConctroller")
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appEnteredBackground), name: UIApplicationWillResignActiveNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appHasComeBackFromBackground), name: UIApplicationDidBecomeActiveNotification, object: nil)
		
		
		
		timer = NSTimer(timeInterval: 10.0, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
		
		if CurrentUser.currentUser.team == "Yellow"{
			self.navigationItem.title = "Team Instinct"
		} else if CurrentUser.currentUser.team == "Blue" {
			self.navigationItem.title = "Team Mystic"
		} else {
			self.navigationItem.title = "Team Valor"
		}
		
		
		myLocationSwitch.on = CurrentUser.currentUser.location
		self.hideKeyboardWhenTappedAround()
		
		inputText.delegate = self
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		//locationManager.requestWhenInUseAuthorization()
		
		let span = MKCoordinateSpanMake(0.02, 0.02)
		let location = CLLocationCoordinate2D.init(latitude: (CurrentUser.currentUser.latitude!),
		                                           longitude: (CurrentUser.currentUser.longitude!))
		
		let region = MKCoordinateRegion(center: location, span: span)
		mapView.setRegion(region, animated: true)
		//locationManager.startUpdatingLocation()
		locationManager.requestLocation()
		
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 140
		myLocationSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75)
		
		let bgImage     = UIImage(named: CurrentUser.currentUser.team)
		let imageView   = UIImageView(frame: tableView.bounds)
		imageView.image = bgImage
		tableView.backgroundView = imageView
		
		let sendBg = UIImage(named: "\(CurrentUser.currentUser.team)OvalSendButton")
		sendButton.setBackgroundImage(sendBg, forState: .Normal)

		
		listenForChatChanges()
    }
	
	func getLocation() {
		if CurrentUser.currentUser.location{
			locationManager.requestLocation()
		}
	}
	
	func listenForChatChanges(){
		Firebase.listenForMessageDataOfType(dataType.TeamMessages, WithKey: chatRoomKey){ [unowned self] (message) in
			//print("got a new message")
			self.messages.append(message)
			//print(self.messages)
			//print("got message into tableView")
			self.tableView.reloadData()
		}
	}
	
	@IBAction func leaveChat(sender: UIBarButtonItem) {
		Firebase.removeUserAtCurrentTeamRoom()
		CurrentUser.inAChatRoom = nil
		Firebase.removeTeamListeners()
		let defaults = NSUserDefaults.standardUserDefaults()
	
		guard !defaults.boolForKey("doneAppRating") && defaults.boolForKey("quitApp") else {
			self.dismissViewControllerAnimated(true, completion: nil);
			return
		}
		
		
		
		let alert = UIAlertController(title: "Rate Pikanect", message: "How do you like this app? We would love to hear your feedback ", preferredStyle: .Alert)
		let rateButton = UIAlertAction(title: "Rate Now!", style: .Default) { [unowned self] (alert) in
			UIApplication.sharedApplication().openURL(NSURL(string : "itms-apps://itunes.apple.com/app/id1136003010")!)
			defaults.setBool(true, forKey: "doneAppRating")
			self.dismissViewControllerAnimated(true, completion: nil)
		}
		
		let dontWantToRate = UIAlertAction(title: "Never remind me again!", style: .Cancel) { (alert) in
			defaults.setBool(true, forKey: "doneAppRating")
		}
		
		
		let remindLater = UIAlertAction(title: "Remind Me Later", style: .Default) { [unowned self] alert in
			defaults.setBool(false, forKey: "doneAppRating")
			defaults.setBool(false, forKey: "quitApp")
			self.dismissViewControllerAnimated(true, completion: nil)
		}
		
		
		alert.addAction(dontWantToRate)
		alert.addAction(remindLater)
		alert.addAction(rateButton)
		
		presentViewController(alert, animated: true, completion: nil)
		
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
		let data = ["text": textField.text!]
		//print(data)
		inputText.endEditing(true)
		inputText.text = ""
		Firebase.saveMessageData(data, OfType: dataType.TeamMessages, WithKey: chatRoomKey)
		return true
	}
	
	@IBAction func sendMessage(sender: UIButton) {
		textFieldShouldReturn(inputText)
	}
	
	
//	func moveKeyboardUp(sender: NSNotification) {
//		let userInfo: [NSObject : AnyObject] = sender.userInfo!
//		let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
//		let offset: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
//		
//		if keyboardSize.height == offset.height {
//			UIView.animateWithDuration(0.1, animations: { () -> Void in
//				self.view.frame.origin.y -= keyboardSize.height
//			})
//		} else {
//			UIView.animateWithDuration(0.1, animations: { () -> Void in
//				self.view.frame.origin.y += keyboardSize.height - offset.height
//			})
//		}
//	}
//	
//	func moveKeyboardDown(sender: NSNotification) {
//		let userInfo: [NSObject : AnyObject] = sender.userInfo!
//		let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
//		self.view.frame.origin.y += keyboardSize.height
//	}

	
	func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
			bottomBarSpaceToAds.constant = keyboardFrame.height
			view.setNeedsLayout()
			view.layoutIfNeeded()
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		bottomBarSpaceToAds.constant = 0
		view.setNeedsLayout()
		view.layoutIfNeeded()
	}
	
	
	
	func appEnteredBackground(sender: NSNotification) {

//		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
		//self.view.userInteractionEnabled = false
		timer.invalidate()
		
	}
	
	func appHasComeBackFromBackground(sender: NSNotification) {
		print("back from background")
		
		
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moveKeyboardUp), name: UIKeyboardWillShowNotification, object: nil)
//		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(moveKeyboardDown), name: UIKeyboardWillHideNotification, object: nil)
//		inputText.becomeFirstResponder()
		
		timer = NSTimer(timeInterval: 10.0, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
		timer.fire()
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
		
	}

	
	
}


//MARK: tableView
extension TeamChatViewController: UITableViewDataSource, UITableViewDelegate, ChatCellDelegate{
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return messages.count
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		//print("making cell...")
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
			AlertControllers.displayAlertWithtitle("Reported Message Confirmation", message: "The meesage has been reported to the admins")
			Firebase.reportMessageWithKey(cell.messageKey, WithMessage: cell.message.text!, ByUser: cell.userID, inRoomType: "Team")
			//self.dismissViewControllerAnimated(true, completion: nil)
		}
		
		alert.addAction(cancelButton)
		alert.addAction(reportButton)
		
		presentViewController(alert, animated: true, completion: nil)
	}
	
	
	func blockUserOnCell(cell: DisplayMessageTableViewCell) {
		if CurrentUser.currentUser.id == cell.userID {
			AlertControllers.displayAlertWithtitle("That's You!", message: "You can't block yourself!")
		} else{
			AlertControllers.blockUserWithIDWithCompletionIfBlocked(cell.userID) {
				self.messages = []
				Firebase.removeTeamListeners()
				self.listenForChatChanges()
				self.tableView.reloadData()
			}
			
		}

		
	}
}


//MARK: Map stuff
extension TeamChatViewController: MKMapViewDelegate {
	
	func refreshMapView(){
		users.removeAll()
		let allAnnotations = self.mapView.annotations
		self.mapView.removeAnnotations(allAnnotations)
		
		let teamKey = CurrentUser.currentTeamChatRoomKey
		Firebase.getUsersFromTeamWithKey(teamKey) { (user) in
			self.users.append(user)
			print(user)
		}
		
	}
	
	func placePinAtLongitude(longitude: Double?, latitude: Double?, userName: String) {
		
		if let latitude = latitude {
			let pin = MapPin(title: userName, coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude!)))
			//If the latitude is there, then the longitude will be there too
			mapView.addAnnotation(pin)
		}
	}
	
	//put annotation of the map. Function called automatically by mapView
	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		if let annotation = annotation as? MapPin {
			let identifier = "pin"
			var view: MKPinAnnotationView
			
			if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
				dequeuedView.annotation = annotation
				view = dequeuedView
			} else {
				view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
				view.canShowCallout = true
				view.calloutOffset = CGPoint(x: -5, y: 5)
			}
			
			view.pinTintColor = CurrentUser.currentUser.getTeamUIColor()

			
			return view
		}
		return nil
	}
}
extension TeamChatViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard CurrentUser.currentUser.location else { return }
		
		if let location = locations.last {
			//print("\n\nPRINTING LOCATION FROM TEAM\n\n")
			//print("location:: \(location.coordinate)")
			Firebase.saveLocationOfUserWithKey(CurrentUser.currentUser.id, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
			
			CurrentUser.currentUser.latitude = location.coordinate.latitude
			CurrentUser.currentUser.longitude = location.coordinate.longitude
			
			refreshMapView()
			//locationManager.stopUpdatingLocation()
		}
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("ERROR!!")
		print("error:: \(error)")
		if self.presentedViewController == nil {
			AlertControllers.displayErrorAlert("Please check that location services are turned on for this app", error: error.debugDescription, instance: "updating location")
		}
		
	}

}
