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
	let scrumVariationAllowed: Double = 20.0*60//min
	let lunchUsualHour = 13
	let lunchUsualMinute = 0
	let lunchVariationAllowed: Double = 60.0*60//min
	
	func taskTypeAroundDate (date: NSDate) -> TaskType {
		
		// Check if the date is around scrum time
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: date)
		comps.hour = scrumUsualHour
		comps.minute = scrumUsualMinute
		comps.second = 0
		let scrumDate = gregorian!.dateFromComponents(comps)
		var timestamp = date.timeIntervalSinceDate(scrumDate!)
		
		if abs(timestamp) <= scrumVariationAllowed {
			return TaskType.Scrum
		}
		
		
		// Check if the date is around lunch break
		
		comps.hour = lunchUsualHour
		comps.minute = lunchUsualMinute
		comps.second = 0
		let lunchDate = gregorian!.dateFromComponents(comps)
		timestamp = date.timeIntervalSinceDate(lunchDate!)
		
		if abs(timestamp) <= lunchVariationAllowed {
			return TaskType.Lunch
		}
		
		return TaskType.Issue
	}
}
