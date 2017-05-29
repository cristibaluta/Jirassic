//
//  TaskTypeEstimator.swift
//  Jirassic
//
//  Created by Baluta Cristian on 04/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskTypeEstimator {

	fileprivate let scrumVariationAllowed = 20.0.minToSec
	fileprivate let lunchVariationAllowed = 60.0.minToSec
	
    func taskTypeAroundDate (_ date: Date, withSettings settings: Settings) -> TaskType {
		
		// Check if the date is around scrum time
        var settingsScrumTime = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.scrumTime)
		
		var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: date)
		comps.hour = settingsScrumTime.hour
		comps.minute = settingsScrumTime.minute
		comps.second = 0
		let scrumDate = gregorian.date(from: comps)
		var timestamp = date.timeIntervalSince(scrumDate!)
		
		if abs(timestamp) <= scrumVariationAllowed {
			return TaskType.scrum
		}
		
		
        // Check if the date is around lunch break
        var settingsLunchTime = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.lunchTime)
		
		comps.hour = settingsLunchTime.hour
		comps.minute = settingsLunchTime.minute
		comps.second = 0
		let lunchDate = gregorian.date(from: comps)
		timestamp = date.timeIntervalSince(lunchDate!)
		
		if abs(timestamp) <= lunchVariationAllowed {
			return TaskType.lunch
		}
        
        // Check if enough time to be considered a meeting
        if abs(date.timeIntervalSinceNow) > Double(settings.minSleepDuration) {
            return TaskType.meeting
        }
        
		return TaskType.issue
	}
}
