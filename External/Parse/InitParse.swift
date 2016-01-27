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
		Parse.enableLocalDatastore()// This does not work with cache enabled
		#if os(OSX)
			PFUser.enableAutomaticUser()
		#endif
		
		Parse.setApplicationId(parseApplicationId, clientKey:parseClientId)
		
		let acl = PFACL()
		acl.publicReadAccess = false
		PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
		
		_ = PFAnalytics()
	}
}
