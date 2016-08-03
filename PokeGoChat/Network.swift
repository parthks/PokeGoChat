//
//  Network.swift
//  Pikanect
//
//  Created by Parth Shah on 27/07/16.
//  Copyright © 2016 Parth Shah. All rights reserved.
//

import Foundation
import UIKit //for download image function


struct NetInfo {
	let ip: String
	let netmask: String
}

class Network {
	// Get the local ip addresses used by this node
	static func getLocalAddress() -> NetInfo? {
		var addresses = [NetInfo]()
		
		// Get list of all interfaces on the local machine:
		var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
		if getifaddrs(&ifaddr) == 0 {
			var ptr = ifaddr
			while(ptr != nil) {
				let flags = Int32(ptr.memory.ifa_flags)
				var addr = ptr.memory.ifa_addr.memory
				
				// Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
				if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
					if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
						
						// Convert interface address to a human readable string:
						var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
						if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
							nil, socklen_t(0), NI_NUMERICHOST) == 0) {
							if let address = String.fromCString(hostname) {
								
								var net = ptr.memory.ifa_netmask.memory
								var netmaskName = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
								getnameinfo(&net, socklen_t(net.sa_len), &netmaskName, socklen_t(netmaskName.count),
								            nil, socklen_t(0), NI_NUMERICHOST) == 0
								if let netmask = String.fromCString(netmaskName) {
									addresses.append(NetInfo(ip: address, netmask: netmask))
								}
							}
						}
					}
				}
				ptr = ptr.memory.ifa_next
				
			}
			//			// For each interface ...
			//			for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
			//							}
			freeifaddrs(ifaddr)
		}
		
		return addresses.last
	}
	
	
	static func getPublicIpAddress() -> String? {
		do {
			return try String(contentsOfURL: NSURL(string: "https://icanhazip.com/")!)
		} catch {
			return nil
		}
	
	}
	
	static func downloadedFrom(link: String?, completion: UIImage? -> Void) {
		guard let url = NSURL(string: link ?? "") else { return }
		
		print("TRYING TO GET IMAGE")
		
		NSURLSession.sharedSession().dataTaskWithURL(url) { (data, _, error) in
			guard
				let data = data where error == nil,
				let image = UIImage(data: data)
				else { print("ERROR GETTING IMAGE") ;completion(nil); return }
			
			print("GOT IMAGE!")
			dispatch_async(dispatch_get_main_queue()) {
				completion(image)
			}
			
			return
		}.resume()
	}

	
	

}
