//
//  MainScreenViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 13/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds


class MainScreenViewController: UIViewController {

	
	@IBOutlet weak var teamChat: UIButton!
	@IBOutlet weak var generalChat: UIButton!
	
	@IBOutlet weak var bannerView: GADBannerView!
	@IBOutlet weak var gettingLocationLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var locationManager = CLLocationManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.view.sendSubviewToBack(mapView)
		print("enterned main screen")
		bannerView.adUnitID = "ca-app-pub-5358505853496020/9547069190"
		bannerView.rootViewController = self
		let request = GADRequest()
//		request.testDevices = ["9ad72e72a0ec1557d7c004795a25aab9"]
		bannerView.loadRequest(request)
		
		//Firebase.loginWithEmail("location@test.com", AndPassword: "123456"){ key in print("back...")}
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		//locationManager.requestLocation()
		
//		let bgImage     = UIImage(named: CurrentUser.currentUser.team)
//		let bgimageView   = UIImageView(frame: self.view.bounds)
//		bgimageView.image = bgImage
//		self.view.addSubview(bgimageView)
//		self.view.sendSubviewToBack(bgimageView)
		
		let teamBgImage = UIImage(named: "\(CurrentUser.currentUser.team)Rect")
		teamChat.setBackgroundImage(teamBgImage, forState: .Normal)
		
		let navImage     = UIImage(named: "\(CurrentUser.currentUser.team)NavBar")
		generalChat.layer.borderColor = UIColor.blackColor().CGColor
		generalChat.layer.borderWidth = 2
		if CurrentUser.currentUser.team == "Yellow" {
			teamChat.layer.borderColor = UIColor.yellowColor().CGColor
		} else if CurrentUser.currentUser.team == "Red" {
			teamChat.layer.borderColor = UIColor.redColor().CGColor
		} else {
			teamChat.layer.borderColor = UIColor.blueColor().CGColor
		}
		teamChat.layer.borderWidth = 2

	UINavigationBar.appearance().setBackgroundImage(navImage!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 0, 0, 0), resizingMode: .Stretch), forBarMetrics: .Default)

		UINavigationBar.appearance().shadowImage = UIImage()
		
	}

	
	@IBAction func teamChatGo(sender: UIButton) {
		guard self.connectedToNetwork() else  {
			AlertControllers.displayErrorAlert("Invalid Internet connection. Please try later.", error: "lost internet connection", instance: "team chat button pressed")
			return
		}
		
		teamChat.enabled = false
		locationManager.requestLocation()
		if let roomKey = GetChatRoomKey() {
			print("trying to get the team room key")
			roomKey.returnTeamRoomKeyWithBlock() { [unowned self]key in
				print("GOT A TEAM CHAT ROOM")
				self.performSegueWithIdentifier("teamChat", sender: key)
			}
		}
		teamChat.enabled = true

	}
	
	
	@IBAction func generalChatGo(sender: UIButton) {
		guard self.connectedToNetwork() else  {
			AlertControllers.displayErrorAlert("Invalid Internet connection. Please try later.", error: "lost internet connection", instance: "general chat button pressed")
			return
		}
		generalChat.enabled = false
		locationManager.requestLocation()
		if let roomKey = GetChatRoomKey() {
			print("trying to get the gen room key")
			roomKey.returnGeneralRoomKeyWithBlock() {[unowned self] key in
				print("GOT A GEN CHAT ROOM")
				self.performSegueWithIdentifier("generalChat", sender: key)
			}
		}
		generalChat.enabled = true
		
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

	var main_timer = NSTimer()
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		main_timer = NSTimer(timeInterval: 10.0, target: self, selector: #selector(getLocation), userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(main_timer, forMode: NSRunLoopCommonModes)
		
	}
	
	func getLocation(){
		locationManager.startUpdatingLocation()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		main_timer.invalidate()
	}
		
}


extension MainScreenViewController: CLLocationManagerDelegate {
	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		if status == .AuthorizedWhenInUse {
			locationManager.requestLocation()
		}
	}
 
	func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		
		if gettingLocationLabel.text == "Getting Location" {
			activityIndicator.stopAnimating()
			gettingLocationLabel.hidden = true
		}
	
		if let location = locations.last {
			print("PRINTING LOCATION FROM MAIN")
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
		
		locationManager.stopUpdatingLocation()
	}
 
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("ERROR!!")
		print("error:: \(error)")
		if self.presentedViewController == nil {
			AlertControllers.displayErrorAlert("Please check that location services are turned on for this app", error: error.debugDescription, instance: "updating loaction")
		}
		
	}
}

