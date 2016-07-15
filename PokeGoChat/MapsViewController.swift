//
//  MapsViewController.swift
//  test
//
//  Created by Parth Shah on 11/07/16.
//  Copyright © 2016 testFirebase. All rights reserved.
//

import UIKit
import MapKit

class MapsViewController: UIViewController {

	@IBOutlet weak var labelBelowMap: UILabel!
	@IBOutlet weak var mapView: MKMapView!
	
	var users = [User]() {
		didSet{
			self.labelBelowMap.text = "Displaying location of \(self.users.count) teammates"
			self.placePinAtLongitude(users.last!.longitude, latitude: users.last!.latitude, userName: (users.last!.name))
		}
	}
	//var currentLocation: (latitude: Double, longitude: Double) = (CurrentUser.currentUser.latitude!,
	//CurrentUser.currentUser.longitude!)
	
	
//	override func viewDidLoad() {
//		let span = MKCoordinateSpanMake(0.01, 0.01)
//		let location = CLLocationCoordinate2D.init(latitude: CLLocationDegrees(CurrentUser.currentUser.latitude!),
//		                                           longitude: CLLocationDegrees(CurrentUser.currentUser.longitude!))
//		
//		let region = MKCoordinateRegion(center: location, span: span)
//		mapView.setRegion(region, animated: true)
//
//	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let span = MKCoordinateSpanMake(0.015, 0.015)
		let location = CLLocationCoordinate2D.init(latitude: (CurrentUser.currentUser.latitude!),
		                                           longitude: (CurrentUser.currentUser.longitude!))
		
		let region = MKCoordinateRegion(center: location, span: span)
		mapView.setRegion(region, animated: true)
		
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
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

extension MapsViewController: MKMapViewDelegate {
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
			return view
		}
		return nil
	}
}
