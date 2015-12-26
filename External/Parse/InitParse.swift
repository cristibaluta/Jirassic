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
		
		PTask.registerSubclass()
		PUser.registerSubclass()
		PIssue.registerSubclass()
		
		#if os(OSX)
			Parse.enableLocalDatastore()// This does not work with cache enabled
			PFUser.enableAutomaticUser()
		#endif
		
		let acl = PFACL()
		acl.setPublicReadAccess(false)
		PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
		
		Parse.setApplicationId(parseApplicationId, clientKey:parseClientId)
		
		_ = PFAnalytics()
	}
}
