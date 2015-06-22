//
//  User.swift
//  Jirassic
//
//  Created by Baluta Cristian on 14/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

public class JRUser: PFUser, JRUserProtocol {
	
//	public override class func parseClassName() -> String {
//		return "JRUser"
//	}
//	
	var isLoggedIn: Bool {
		get {
			var currentUser = PFUser.currentUser()
			return (currentUser != nil && currentUser!.username != nil)
		}
	}
}
