//
//  User.swift
//  Jirassic
//
//  Created by Baluta Cristian on 14/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

public class PUser: PFUser {
	
	var isLoggedIn: Bool {
		get {
//			RCLogO(self.isAuthenticated())
			RCLogO(self.username)
			return (self.username != nil)
		}
	}
}
