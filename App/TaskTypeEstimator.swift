//
//  Estimator.swift
//  Jirassic
//
//  Created by Baluta Cristian on 04/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskTypeEstimator: NSObject {

	let scrumUsualHour = 10
	let scrumUsualMinute = 30
	let scrumVariationAllowed: Double = 15.0*60//min
	let lunchUsualHour = 13
	let lunchUsualMinute = 0
	
	func taskTypeAroundDate(date: NSDate) -> TaskType {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: date)
		comps.hour = scrumUsualHour
		comps.minute = scrumUsualMinute
		comps.second = 0
		let scrumDate = gregorian!.dateFromComponents(comps)
		let timestamp = date.timeIntervalSinceDate(scrumDate!)
		RCLogO(date)
		RCLogO(scrumDate)
		RCLogO(timestamp)
		
		if (abs(timestamp) < scrumVariationAllowed) {
			return TaskType.Scrum
		}
		
		return TaskType.Issue
	}
}
