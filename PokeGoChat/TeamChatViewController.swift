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

class TeamChatViewController: UIViewController {

	//static var numberOfUsers = 0
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var inputText: UITextField!
	@IBOutlet weak var myLocationSwitch: UISwitch!
	@IBOutlet weak var mapView: MKMapView!
	
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
	
	
	override func viewDidDisappear(animated: Bool) {
		locationManager.stopUpdatingLocation()
	}
	
	@IBAction func locationChanged(sender: UISwitch) {
		CurrentUser.currentUser.location = myLocationSwitch.on
		Firebase.saveUser(CurrentUser.currentUser, WithKey: CurrentUser.currentUser.id)
		print("UPDATED LOCATION")
	}
	
	var messages: [FIRDataSnapshot] = []
	var chatRoomKey: String = ""
	
	let maxMesLength = 140 //in characters - a tweet!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let timer = NSTimer(timeInterval: 5.0, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
		
		self.navigationItem.title = "Team \(CurrentUser.currentUser.team)"
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
		
		listenForChatChanges()
    }
	
	func getLocation() {
		if CurrentUser.currentUser.location{
			locationManager.requestLocation()
		}
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
		//mapView = nil
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
		if name == CurrentUser.currentUser.name {
			
		}
		cell.textLabel?.text = name
		cell.detailTextLabel?.text = text
		return cell
	}
}


//MARK: Map stuff
extension TeamChatViewController: MKMapViewDelegate {
	
	func refreshMapView(){
		users.removeAll()
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
			
			
			if CurrentUser.currentUser.team == "Red"{
				view.pinTintColor = UIColor.redColor()
			}else if CurrentUser.currentUser.team == "Blue"{
				view.pinTintColor = UIColor.blueColor()
			}else{
				view.pinTintColor = UIColor.yellowColor()
			}

			
			return view
		}
		return nil
	}
}
extension TeamChatViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if let location = locations.last {
			print("location:: \(location.coordinate)")
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
	}

}
