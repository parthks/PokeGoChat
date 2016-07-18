//
//  MainScreenViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 13/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import MapKit
import iAd

class MainScreenViewController: UIViewController {

	
	@IBOutlet weak var teamChat: UIButton!
	@IBOutlet weak var generalChat: UIButton!
	
	@IBOutlet weak var gettingLocationLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var locationManager = CLLocationManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		//Firebase.loginWithEmail("location@test.com", AndPassword: "123456"){ key in print("back...")}
		canDisplayBannerAds = true
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		//locationManager.requestLocation()
	}

	
	@IBAction func teamChatGo(sender: UIButton) {
		locationManager.requestLocation()
		let roomKey = GetChatRoomKey()
		roomKey.returnTeamRoomKeyWithBlock() { key in
			self.performSegueWithIdentifier("teamChat", sender: key)
		}

	}
	
	
	@IBAction func generalChatGo(sender: UIButton) {
		locationManager.requestLocation()
		let roomKey = GetChatRoomKey()
		roomKey.returnGeneralRoomKeyWithBlock() { key in
			self.performSegueWithIdentifier("generalChat", sender: key)
		}
	}
	
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "teamChat"{
			let destinationNav = segue.destinationViewController as! UINavigationController
			let destination = destinationNav.viewControllers[0] as! TeamChatViewController
			destination.chatRoomKey = sender as! String
			
		} else if segue.identifier == "generalChat"{
			let destinationNav = segue.destinationViewController as! UINavigationController
			let destination = destinationNav.viewControllers[0] as! GeneralChatViewController
			print(sender as? String)
			destination.chatRoomKey = sender as! String
			
			
		}
	}

	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		locationManager.requestLocation()
	}
	
}

extension MainScreenViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == .AuthorizedWhenInUse {
			locationManager.requestLocation()
		}
	}
 
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		activityIndicator.stopAnimating()
		gettingLocationLabel.hidden = true
		
		if let location = locations.last {
			print("location:: \(location.coordinate)")
	
			let span = MKCoordinateSpanMake(0.005, 0.005)
			let region = MKCoordinateRegion(center: location.coordinate, span: span)
			mapView.setRegion(region, animated: true)
			
			Firebase.saveLocationOfUserWithKey(CurrentUser.currentUser.id, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
			
			CurrentUser.currentUser.latitude = location.coordinate.latitude
			CurrentUser.currentUser.longitude = location.coordinate.longitude
			
			teamChat.enabled = true
			generalChat.enabled = true
		}
	}
 
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("ERROR!!")
		print("error:: \(error)")
	}
}
