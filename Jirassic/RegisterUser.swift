//
//  RegisterUser.swift
//  Jirassic
//
//  Created by Baluta Cristian on 14/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class RegisterUser: NSObject {

	var onRegisterSuccess: (() -> ())?
	var credentials: LoginCredentials?
	
	convenience init (credentials: LoginCredentials) {
		self.init()
		self.credentials = credentials
	}
	
	func register() {
		
		let user = PFUser()
		user.username = credentials!.email
		user.email = credentials!.email
		user.password = credentials!.password
		user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
			if let error = error {
				let errorString = error.userInfo["error"] as? NSString
				RCLogO(errorString)
			} else {
				self.onRegisterSuccess!()
			}
		}
	}
}
