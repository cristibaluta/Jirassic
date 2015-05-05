//
//  NewDayController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 05/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NewDayController: NSObject {
	
	private let kLastStartDateKey = "LastStartDateKey"
	
	func isNewDay() -> Bool {
		return lastDay() != nil && lastDay()!.isSameDayAs( today())
	}
	
	func lastDay() -> NSDate? {
		return NSUserDefaults.standardUserDefaults().objectForKey(kLastStartDateKey) as? NSDate
	}
	
	func setLastDay(date: NSDate) {
		NSUserDefaults.standardUserDefaults().setObject(date, forKey: kLastStartDateKey)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	func today() -> NSDate {
		return NSDate()
	}
}
