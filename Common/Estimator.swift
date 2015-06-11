//
//  Estimator.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 04/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class Estimator: NSObject {

	let scrumUsualHour = 10
	let scrumUsualMinute = 30
	let lunchUsualHour = 13
	let lunchUsualMinute = 0
	
	func taskAroundDate(date: NSDate) -> TaskType {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: NSDate())
		comps.hour = scrumUsualHour
		comps.minute = scrumUsualMinute
		let scrumDate = gregorian!.dateFromComponents(comps)
		
		let timestamp = date.timeIntervalSinceDate(scrumDate!)
		
		if (abs(timestamp) > 15*60) {
			return TaskType.Scrum
		}
		
		return TaskType.Issue
	}
}
