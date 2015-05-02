//
//  InitParse.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class InitParse: NSObject {

	override init() {
		
		// [Optional] Power your app with Local Datastore. For more info, go to
		// https://parse.com/docs/ios_guide#localdatastore/OSX
		
		Task.registerSubclass()
		
		Parse.enableLocalDatastore()
		
		Parse.setApplicationId("DFWPmEOCnRCody7tfeXjzNZAl6nKCaTZELWSEeyZ",
			clientKey:"WdjHVrrPJexhd4nnFZyOx9GoqsBdOCMck5W2qdrd")
		
		PFAnalytics()
	}
}
