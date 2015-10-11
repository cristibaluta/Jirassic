//
//  NewDay.swift
//  Jirassic
//
//  Created by Baluta Cristian on 05/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class NewDay: NSObject {
	
	private let kLastStartDateKey = "LastStartDateKey"
	
	func isNewDay() -> Bool {
		let date = lastTrackedDay()
		return date == nil || !date!.isSameDayAs(today())
	}
	
	func setLastTrackedDay(date: NSDate) {
		NSUserDefaults.standardUserDefaults().setObject(date, forKey: kLastStartDateKey)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	private func lastTrackedDay() -> NSDate? {
		return NSUserDefaults.standardUserDefaults().objectForKey(kLastStartDateKey) as? NSDate
	}
	
	private func today() -> NSDate {
		return NSDate()
	}
}
