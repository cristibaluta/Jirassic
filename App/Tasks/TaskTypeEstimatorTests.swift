//
//  TaskTypeEstimatorTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 11/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic

class TaskTypeEstimatorTests: XCTestCase {
	
	let estimator = TaskTypeEstimator()
    let settings = Settings(autotrack: true,
                            autotrackingMode: TrackingMode(rawValue: TrackingMode.auto.rawValue)!,
                            trackLunch: true,
                            trackScrum: true,
                            trackMeetings: true,
                            trackCodeReviews: true,
                            trackWastedTime: true,
                            trackStartOfDay: true,
                            enableBackup: false,
                            startOfDayTime: Date(hour: 9, minute: 0),
                            endOfDayTime: Date(hour: 17, minute: 0),
                            lunchTime: Date(hour: 13, minute: 0),
                            scrumTime: Date(hour: 10, minute: 30),
                            minSleepDuration: Date(hour: 0, minute: 20),
                            minCodeRevDuration: Date(hour: 0, minute: 5),
                            codeRevLink: "bitbucket",
                            minWasteDuration: Date(hour: 0, minute: 5),
                            wasteLinks: ["facebook.com", "twitter.com"]
    )
    
	func testScrumBeginAt10_30() {
        let date = Date(hour: 10, minute: 30)
		let taskType = estimator.taskTypeAroundDate(date, withSettings: settings)
		XCTAssert(taskType == TaskType.scrum, "")
	}
	
	func testScrumBeginAt_10_50() {
		let date = Date(hour: 10, minute: 50)
		let taskType = estimator.taskTypeAroundDate(date, withSettings: settings)
		XCTAssert(taskType == TaskType.scrum, "")
	}
	
	func testScrumBeginAt_10_10() {
		let date = Date(hour: 10, minute: 10)
		let taskType = estimator.taskTypeAroundDate(date, withSettings: settings)
		XCTAssert(taskType == TaskType.scrum, "")
	}
	
	func testScrumCantBeginAt_11() {
		let date = Date(hour: 11, minute: 0)
		let taskType = estimator.taskTypeAroundDate(date, withSettings: settings)
		XCTAssertFalse(taskType == TaskType.scrum, "")
	}
	
	func testLunchBeginAt_12() {
		let date = Date(hour: 12, minute: 0)
		let taskType = estimator.taskTypeAroundDate(date, withSettings: settings)
		XCTAssert(taskType == TaskType.lunch, "")
	}
	
	func testLunchBeginAt_12_30() {
		let date = Date(hour: 12, minute: 30)
		let taskType = estimator.taskTypeAroundDate(date, withSettings: settings)
		XCTAssert(taskType == TaskType.lunch, "")
	}
	
	func testLunchBeginAt_14() {
		let date = Date(hour: 14, minute: 0)
		let taskType = estimator.taskTypeAroundDate(date, withSettings: settings)
		XCTAssert(taskType == TaskType.lunch, "")
	}
	
	func testLunchTooLate() {
		let date = Date(hour: 15, minute: 0)
		let taskType = estimator.taskTypeAroundDate(date, withSettings: settings)
		XCTAssertFalse(taskType == TaskType.lunch, "")
	}
    
}
