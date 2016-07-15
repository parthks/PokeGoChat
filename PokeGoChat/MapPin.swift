//
//  MapPin.swift
//  PokeGoChat
//
//  Created by Parth Shah on 14/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import MapKit

class MapPin: NSObject, MKAnnotation {
	let title: String?
	var coordinate: CLLocationCoordinate2D
	
	init(title: String, coordinate: CLLocationCoordinate2D) {
		self.title = title
		self.coordinate = coordinate
		super.init()
	}
}