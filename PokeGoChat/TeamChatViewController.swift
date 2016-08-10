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
	
	var selectedCellUser: User!
	var selectedCellUserStatus: Int = -2
	
	var images = [String: UIImage]()
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
	}
	
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appEnteredBackground), name: UIApplicationWillResignActiveNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(appHasComeBackFromBackground), name: UIApplicationDidBecomeActiveNotification, object: nil)
		tableView.reloadData()

	}
	

	
	
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
	
	
	func initBanner(){
		bannerView.adUnitID = Constants.bannerAdUnitID
		bannerView.rootViewController = self
		bannerView.loadRequest(Constants.bannerAdRequest)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		initBanner()
		
		self.navigationItem.title = Constants.getPokemonTeamNameOfColorTeam(CurrentUser.currentUser.team)
		
		timer = NSTimer(timeInterval: 5.0, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		
		let span = MKCoordinateSpanMake(0.02, 0.02)
		let location = CLLocationCoordinate2D.init(latitude: (CurrentUser.currentUser.latitude!),
		                                           longitude: (CurrentUser.currentUser.longitude!))
		
		let region = MKCoordinateRegion(center: location, span: span)
		mapView.setRegion(region, animated: true)
		locationManager.requestLocation()
		
		
		
		
		myLocationSwitch.on = CurrentUser.currentUser.location
		myLocationSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75)

		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.estimatedRowHeight = 140
		tableView.backgroundView = Constants.getImageViewWithName(CurrentUser.currentUser.team, WithBounds: tableView.bounds)

		
		let sendBg = UIImage(named: "\(CurrentUser.currentUser.team)OvalSendButton")
		sendButton.setBackgroundImage(sendBg, forState: .Normal)
		
		
		inputText.delegate = self
		listenForChatChanges()
    }
	
	
	func getLocation() {
		if CurrentUser.currentUser.location{
			locationManager.requestLocation()
		}
		refreshMapView()
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
		timer.invalidate()
		let defaults = NSUserDefaults.standardUserDefaults()
		Firebase.removeTeamListeners()
		
		guard !defaults.boolForKey("doneAppRating") && defaults.boolForKey("quitApp") else {
			self.dismissViewControllerAnimated(true, completion: nil)
			return
		}
		AlertControllers.rateMyApp()
		//self.dismissViewControllerAnimated(true, completion: nil)
	}
	
}


//MARK: textField
extension TeamChatViewController: UITextFieldDelegate{
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		guard let text = textField.text else {return true}
		let newLength = text.utf16.count + string.utf16.count - range.length
		return newLength <= maxMesLength

	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		guard textField.text != "" else {return true}
		let data = ["text": textField.text!]

		inputText.endEditing(true)
		inputText.text = ""
		Firebase.saveMessageData(data, OfType: dataType.TeamMessages, WithKey: chatRoomKey)
		return true
	}
	
	@IBAction func sendMessage(sender: UIButton) {
		textFieldShouldReturn(inputText)
	}
	
	
	func keyboardWillShow(notification: NSNotification) {
		if let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue {
			bottomBarSpaceToAds.constant = keyboardFrame.height
			view.setNeedsLayout()
			view.layoutIfNeeded()
			self.hideKeyboardWhenTappedAround()
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		bottomBarSpaceToAds.constant = 0
		view.setNeedsLayout()
		view.layoutIfNeeded()
		self.removeKeyboardTappingRecognizer()
	}
	
	
	
	func appEnteredBackground(sender: NSNotification) {
		timer.invalidate()
		
	}
	
	func appHasComeBackFromBackground(sender: NSNotification) {
		print("back from background")
		
		timer = NSTimer(timeInterval: 5.0, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
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
		
		if images.indexForKey(user.id) == nil {
			Network.downloadedFrom(user.profilePicUrl) { [unowned self] image in
				guard ((UIApplication.topViewController() as? TeamChatViewController) != nil) else {return}
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
			Firebase.reportMessageWithKey(cell.messageKey, WithMessage: cell.message.text!, ByUser: cell.userID, inRoomType: "Team")

		}
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
	
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
