//
//  TaskTypeEstimator.swift
//  Jirassic
//
//  Created by Baluta Cristian on 04/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskTypeEstimator {

	private let scrumVariationAllowed = 20.0.minToSec
	private let lunchVariationAllowed = 60.0.minToSec
	
    func taskTypeAroundDate (_ date: Date, withSettings settings: Settings) -> TaskType {
		
		// Check if the date is around scrum time
        let settingsScrumTime = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.settingsTracking.scrumTime)

		var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: date)
		comps.hour = settingsScrumTime.hour
		comps.minute = settingsScrumTime.minute
		comps.second = 0
		let scrumDate = gregorian.date(from: comps)
		
        if date.isAlmostSameHourAs(scrumDate!, devianceSeconds: scrumVariationAllowed) {
            return TaskType.scrum
        }

        // Check if the date is around lunch break
        let settingsLunchTime = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.settingsTracking.lunchTime)

		comps.hour = settingsLunchTime.hour
		comps.minute = settingsLunchTime.minute
		comps.second = 0
		let lunchDate = gregorian.date(from: comps)
		
		if date.isAlmostSameHourAs(lunchDate!, devianceSeconds: lunchVariationAllowed) {
			return TaskType.lunch
		}
        
        // Check if enough time to be considered a meeting
        if abs(date.timeIntervalSinceNow) > Double(settings.settingsTracking.minSleepDuration) {
            return TaskType.meeting
        }
        
		return TaskType.issue
	}
}
