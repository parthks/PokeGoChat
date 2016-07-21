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
		print("enterned main screen")
		bannerView.adUnitID = "ca-app-pub-5358505853496020/9547069190"
		bannerView.rootViewController = self
		let request = GADRequest()
		request.testDevices = ["9ad72e72a0ec1557d7c004795a25aab9"]
		bannerView.loadRequest(request)
		
//		let defaults = NSUserDefaults.standardUserDefaults()
//		if let inAChat = defaults.stringForKey("inAChat") {
//			if inAChat == "team" {
//				print("team stuff..")
//				CurrentUser.currentTeamChatRoomKey = defaults.stringForKey("teamRoomKey")!
//				CurrentFirebaseLocationData.RoundedLocation = defaults.stringForKey("roundedLoc")!
//				Firebase.removeTeamRoomAtRoundedCoor()
//			}
//		}
	
		//Firebase.loginWithEmail("location@test.com", AndPassword: "123456"){ key in print("back...")}
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		//locationManager.requestLocation()
		
		let bgImage     = UIImage(named: CurrentUser.currentUser.team)
		let bgimageView   = UIImageView(frame: self.view.bounds)
		bgimageView.image = bgImage
		self.view.addSubview(bgimageView)
		self.view.sendSubviewToBack(bgimageView)
		
		let teamBgImage = UIImage(named: "\(CurrentUser.currentUser.team)Rect")
		teamChat.setBackgroundImage(teamBgImage, forState: .Normal)
		
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
	
	deinit {
		print("removed main timer...")
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
		activityIndicator.stopAnimating()
		gettingLocationLabel.hidden = true
		
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
	}
}
