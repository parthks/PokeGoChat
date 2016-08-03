//
//  Constants.swift
//  Pikanect
//
//  Created by Parth Shah on 28/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import UIKit //for UIImageView
import GoogleMobileAds

class Constants {
	static let bannerAdUnitID = "ca-app-pub-5358505853496020/9547069190"
	static let bannerAdRequest = GADRequest()
	
	static let image_TriColor = "TriColor"
	
	static func getImageViewWithName(imageName: String, WithBounds imageBounds: CGRect) -> UIImageView {
		let image = UIImage(named: imageName)
		let imageView = UIImageView(frame: imageBounds)
		imageView.image = image
		
		return imageView
	}
	
	static func getPokemonTeamNameOfColorTeam(teamName: String) -> String {
		if teamName == "Yellow"{
			return "Team Instinct"
			
		} else if teamName == "Blue" {
			return "Team Mystic"
			
		} else if teamName == "Red" {
			return "Team Valor"
		
		}
		
		AlertControllers.displayErrorAlert("Could not find Team", error: "team name passed in is not Yellow, Red or Blue", instance: "getPokemonTeamNameOfColorTeam")
		return "Default"
	}
	
	
	
	
	
	
	
}