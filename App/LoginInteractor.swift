//
//  LoginController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 12/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

class LoginInteractor: NSObject {

	var onLoginSuccess: (() -> ())?
	var data: Repository!
	
	convenience init (data: Repository) {
		self.init()
		self.data = data
	}
	
	func loginWithCredentials (credentials: LoginCredentials) {
		
		PUser.logInWithUsernameInBackground(credentials.email, password: credentials.password) {
			[weak self] (user: PFUser?, error: NSError?) -> Void in
			
			if user != nil {
				self?.onLoginSuccess!()
			}
			else if let error = error {
				let errorString = error.userInfo["error"] as? NSString
				RCLogO(errorString)
				
				if let strongSelf = self {
					let registerInteractor = RegisterUserInteractor(data: strongSelf.data)
					registerInteractor.onRegisterSuccess = {
						self?.onLoginSuccess!()
					}
					registerInteractor.registerWithCredentials(credentials)
				}
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
		PUser.logOutInBackgroundWithBlock { (error) -> Void in
			RCLog(error)
			_ = PUser.currentUser() // this will now be nil
		}
	}
}
