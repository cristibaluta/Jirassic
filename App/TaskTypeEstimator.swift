//
//  TaskTypeEstimator.swift
//  Jirassic
//
//  Created by Baluta Cristian on 04/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskTypeEstimator: NSObject {

	let scrumUsualHour = 10
	let scrumUsualMinute = 30
	let scrumVariationAllowed: Double = 20.0.minToSec
	let lunchUsualHour = 13
	let lunchUsualMinute = 0
	let lunchVariationAllowed: Double = 60.0.minToSec
	
	func taskTypeAroundDate (_ date: Date) -> TaskType {
		
		// Check if the date is around scrum time
		
		var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: date)
		comps.hour = scrumUsualHour
		comps.minute = scrumUsualMinute
		comps.second = 0
		let scrumDate = gregorian.date(from: comps)
		var timestamp = date.timeIntervalSince(scrumDate!)
		
		if abs(timestamp) <= scrumVariationAllowed {
			return TaskType.scrum
		}
		
		
		// Check if the date is around lunch break
		
		comps.hour = lunchUsualHour
		comps.minute = lunchUsualMinute
		comps.second = 0
		let lunchDate = gregorian.date(from: comps)
		timestamp = date.timeIntervalSince(lunchDate!)
		
		if abs(timestamp) <= lunchVariationAllowed {
			return TaskType.lunch
		}
		
		return TaskType.issue
	}
}
