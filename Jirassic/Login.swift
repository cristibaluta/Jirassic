//
//  LoginController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 12/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class Login: NSObject {

	var onLoginSuccess: (() -> ())?
	var credentials: LoginCredentials?
	
	convenience init (credentials: LoginCredentials) {
		self.init()
		self.credentials = credentials
	}
	
	func login() {
		
		PFUser.logInWithUsernameInBackground(self.credentials!.email, password: self.credentials!.password) {
			(user: PFUser?, error: NSError?) -> Void in
			if user != nil {
				self.onLoginSuccess!()
			} else if let error = error {
				let errorString = error.userInfo?["error"] as? NSString
				RCLogO(errorString)
				
				let register = RegisterUser(credentials: self.credentials!)
				register.onRegisterSuccess = {
					self.onLoginSuccess!()
				}
				register.register()
			}
		}
	}
}
