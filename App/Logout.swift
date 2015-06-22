//
//  Logout.swift
//  Jirassic
//
//  Created by Baluta Cristian on 14/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class Logout: NSObject {

	func logout() {
		PFUser.logOutInBackgroundWithBlock { (error) -> Void in
			
		}
	}
}
