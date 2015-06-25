//
//  ScrumEstimationTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 11/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest

class TaskTypeEstimatorTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testScrumBeginAt10_30() {
		let date = NSDate.dateWithHour(10, minute: 30)
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumBeginAt_10_50() {
		let date = NSDate.dateWithHour(10, minute: 50)
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumBeginAt_10_10() {
		let date = NSDate.dateWithHour(10, minute: 10)
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumCantBeginAt_11() {
		let date = NSDate.dateWithHour(11, minute: 0)
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssertFalse(taskType == TaskType.Scrum, "Pass")
	}
	
	
	func testLunchBeginAt_12() {
		let date = NSDate.dateWithHour(12, minute: 0)
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Lunch, "Pass")
	}
	
	func testLunchBeginAt_12_30() {
		let date = NSDate.dateWithHour(12, minute: 30)
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Lunch, "Pass")
	}
	
	func testLunchBeginAt_14() {
		let date = NSDate.dateWithHour(14, minute: 0)
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Lunch, "Pass")
	}
	
	func testLunchTooLate() {
		let date = NSDate.dateWithHour(15, minute: 0)
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssertFalse(taskType == TaskType.Lunch, "Pass")
	}
	
}
