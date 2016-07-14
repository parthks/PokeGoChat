//
//  MainScreenViewController.swift
//  PokeGoChat
//
//  Created by Parth Shah on 13/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import MapKit

class MainScreenViewController: UIViewController {

	
	@IBOutlet weak var gettingLocationLabel: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var locationManager = CLLocationManager()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		//Firebase.loginWithEmail("testuser1@test.com", AndPassword: "123456"){ key in print("back...")}

		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyBest
		locationManager.requestWhenInUseAuthorization()
		//activityIndicator.startAnimating()
	
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
		
		if let location = locations.first {
			print("location:: \(location.coordinate)")
			
			Firebase.saveLocationOfUserWithKey(CurrentUser.currentUser.id, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
			
			let span = MKCoordinateSpanMake(0.005, 0.005)
			let region = MKCoordinateRegion(center: location.coordinate, span: span)
			mapView.setRegion(region, animated: true)
			
			CurrentUser.currentUser.latitude = location.coordinate.latitude
			CurrentUser.currentUser.longitude = location.coordinate.longitude
		}
	}
 
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("ERROR!!")
		print("error:: \(error)")
	}
}
