//
//  NewDay.swift
//  Jirassic
//
//  Created by Baluta Cristian on 05/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class NewDay {
	
	fileprivate let kLastStartDateKey = "LastStartDateKey"
	
	func isNewDay() -> Bool {
		let date = lastTrackedDay()
		return date == nil || !date!.isSameDayAs(today())
	}
	
	func setLastTrackedDay (_ date: Date) {
		UserDefaults.standard.set(date, forKey: kLastStartDateKey)
		UserDefaults.standard.synchronize()
	}
	
	fileprivate func lastTrackedDay() -> Date? {
		return UserDefaults.standard.object(forKey: kLastStartDateKey) as? Date
	}
	
	fileprivate func today() -> Date {
		return Date()
	}
}
