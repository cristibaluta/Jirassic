//
//  LoginController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 12/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

class Login: NSObject {

	var onLoginSuccess: (() -> ())?
	var credentials: LoginCredentials?
	
	convenience init (credentials: LoginCredentials) {
		self.init()
		self.credentials = credentials
	}
	
	func login() {
		
		JRUser.logInWithUsernameInBackground(self.credentials!.email, password: self.credentials!.password) {
			(user: PFUser?, error: NSError?) -> Void in
			
			if user != nil {
				self.onLoginSuccess!()
			}
			else if let error = error {
				let errorString = error.userInfo["error"] as? NSString
				RCLogO(errorString)
				
				let register = RegisterUser(credentials: self.credentials!)
				register.onRegisterSuccess = {
					self.onLoginSuccess!()
				}
				register.register()
			}
		}
	}
	
	//	func login() {
	//		var currentUser = PFUser.currentUser()
	//		if currentUser != nil {
	//			// Do stuff with the user
	//		} else {
	//			loginAnonymousUser()
	//		}
	//	}
	//
	//	func loginAnonymousUser() {
	//		PFAnonymousUtils.logInWithBlock {
	//			(user: PFUser?, error: NSError?) -> Void in
	//			if error != nil || user == nil {
	//				RCLogO("Anonymous login failed.")
	//			} else {
	//				RCLogO("Anonymous user logged in.")
	//			}
	//		}
	//	}
	//
	func isAnonymousUser() {
		if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) {
//			self.enableSignUpButton()
		} else {
//			self.enableLogOutButton()
		}
	}
	
	func logout() {
		JRUser.logOutInBackgroundWithBlock { (error) -> Void in
			RCLogO(error)
			var currentUser = JRUser.currentUser() // this will now be nil
		}
	}
}
