//
//  MyFriendsViewController.swift
//  Pikanect
//
//  Created by Parth Shah on 04/08/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import UIKit
import Social

//KEY MAP
//1 -> Normal friend
//2 -> Pending friend - waiting for other person to accept
//0 -> Invited friend - needs to accept or deny friend request
//-1 -> Not a friend - NOT NEEDED HERE
//-2 -> Current user - NOT NEEDED HERE


class MyFriendsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

	@IBOutlet weak var collectionView: UICollectionView!
	
	var friends: [(User, Int)] = []
	var images = [String: UIImage]()

	var friendSelected: User!
	var statusSelected: Int = 1
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return friends.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier("friendPic", forIndexPath: indexPath) as! FriendPicCollectionViewCell
		
		let friend = friends[indexPath.row].0
		let status = friends[indexPath.row].1
		
		
		
		if images.indexForKey(friend.id) == nil {
			Network.downloadedFrom(friend.profilePicUrl) { [unowned self] image in
				guard ((UIApplication.topViewController() as? MyFriendsViewController) != nil) else {return}
				if let image = image {
					self.images[friend.id] = image
					collectionView.reloadData()
				}
			}
		}
		
		cell.friendName.text = friend.name
		if friend.team == "Yellow" {
			cell.friendName.textColor = UIColor.yellowColor()
		} else if friend.team == "Red" {
			cell.friendName.textColor = UIColor.redColor()
		} else if friend.team == "Blue" {
			cell.friendName.textColor = UIColor.blueColor()
		} else {
			cell.friendName.textColor = UIColor.blackColor() //should never happen!
		}
		
		
		cell.friendPic.layer.cornerRadius = 50
		cell.friendPic.layer.masksToBounds = true
		if status == 1 {
			cell.friendPic.layer.borderColor = UIColor.greenColor().CGColor
		} else {
			cell.friendPic.layer.borderColor = UIColor.blackColor().CGColor
		}
		cell.friendPic.contentMode = .ScaleAspectFill
		cell.friendPic.layer.borderWidth = 3
		if images[friend.id] != nil {
			cell.friendPic.image = images[friend.id]
		}
		
		return cell
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		Firebase.getAllFriendsKeyOfCurrnetUserWithBlock() { [unowned self] friendTuple in
			print("added collection view")
			self.friends.append(friendTuple)
			self.collectionView.reloadData()
		}
		
    }

	
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		friendSelected = friends[indexPath.row].0
		statusSelected = friends[indexPath.row].1
		performSegueWithIdentifier("friend", sender: nil)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "friend" {
			let destination = segue.destinationViewController as! DisplayFriendInfoViewController
			destination.friend = friendSelected
			destination.friendStatus = statusSelected
		}
	}

	@IBAction func facebook(sender: AnyObject) {
		let facebookVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
		facebookVC.setInitialText("Check out this great Pokemon Chat App!") //Facebook doesnt allow this anymore :(
		facebookVC.addURL(NSURL(string: "https://itunes.apple.com/app/id1136003010"))
		presentViewController(facebookVC, animated: true, completion: nil)
	}
	
	@IBAction func twitter(sender: AnyObject) {
		let twitterVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
		twitterVC.setInitialText("Check out this great Pokemon Chat App!")
		twitterVC.addURL(NSURL(string: "https://itunes.apple.com/app/id1136003010"))
		presentViewController(twitterVC, animated: true, completion: nil)
	
		
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
