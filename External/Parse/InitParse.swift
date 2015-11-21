//
//  InitParse.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

class InitParse: NSObject {

	override init() {
		
		assert(parseApplicationId != "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
			"You need to create your own Parse app in order to use this. After that put the keys in ParseCredentials.swift")
		
		// [Optional] Power your app with Local Datastore. For more info, go to
		// https://parse.com/docs/ios_guide#localdatastore/OSX
		
		PTask.registerSubclass()
		PUser.registerSubclass()
		PIssue.registerSubclass()
		
//		Parse.enableLocalDatastore()// This does not work with cache enabled
		#if os(OSX)
		PFUser.enableAutomaticUser()
		#endif
//		PFUser.currentUser()!.incrementKey("RunCount")
//		PFUser.currentUser()!.saveInBackground()
		
		let acl = PFACL()
		acl.setPublicReadAccess(false)
		PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
		
		Parse.setApplicationId(parseApplicationId, clientKey:parseClientId)
		_ = PFAnalytics()
	}
}
