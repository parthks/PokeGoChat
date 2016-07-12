//
//  MapsViewController.swift
//  test
//
//  Created by Parth Shah on 11/07/16.
//  Copyright © 2016 testFirebase. All rights reserved.
//

import UIKit

class MapsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
		
//		Firebase.createUserWithEmail("test4@test.com", AndPassword: "test123") { (userKey) in
//			print(userKey)
//		}
		
		Firebase.loginWithEmail("test1@test.com", AndPassword: "test123"){ userKey in
			print("user key: \(userKey)")
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
