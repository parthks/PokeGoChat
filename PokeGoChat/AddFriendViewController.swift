//
//  AddFriendViewController.swift
//  Pikanect
//
//  Created by Parth Shah on 09/08/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var searchBar: UISearchBar!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}

extension AddFriendViewController: UITableViewDataSource, UITableViewDelegate{
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 3
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! AddFriendTableViewCell
		cell.name.text = "User's Name"
		cell.profilePic.image = UIImage(named: "Image")
		return cell
		
	}
}
extension AddFriendViewController: UISearchBarDelegate{

}
