//
//  InitParse.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class InitParse: NSObject {

	override init() {
		
		assert(parseApplicationId != "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
			"You need to create your own Parse app in order to use this. After that put the keys in ParseCredentials")
		
		// [Optional] Power your app with Local Datastore. For more info, go to
		// https://parse.com/docs/ios_guide#localdatastore/OSX
		
		Task.registerSubclass()
		User.registerSubclass()
		
//		Parse.enableLocalDatastore()
		#if os(iOS)
		PFUser.enableAutomaticUser()
		#endif
//		PFUser.currentUser()!.incrementKey("RunCount")
//		PFUser.currentUser()!.saveInBackground()
		
		let acl = PFACL()
		acl.setPublicReadAccess(false)
		PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
		
		Parse.setApplicationId(parseApplicationId, clientKey:parseClientId)
		PFAnalytics()
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
//	func isAnonymousUser() {
//		if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) {
////			self.enableSignUpButton()
//		} else {
////			self.enableLogOutButton()
//		}
//	}
//	
//	func logout() {
//		PFUser.logOut()
//		var currentUser = PFUser.currentUser() // this will now be nil
//	}
}
