//
//  ScrumEstimationTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 11/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest

class TaskTypeEstimatorTests: XCTestCase {
	
	let k10_30_UTC: Double = 1433143800
	let k12_30_UTC: Double = 1433151000
	let k13_UTC: Double = 1433152800
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testScrumBeginAt10_30() {
		let date = NSDate(timeIntervalSince1970: k10_30_UTC)// Mon, 01 Jun 2015 10:30:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumBeginAt_10_50() {
		let date = NSDate(timeIntervalSince1970: k10_30_UTC+20*60)// Mon, 01 Jun 2015 10:50:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumBeginAt_10_10() {
		let date = NSDate(timeIntervalSince1970: k10_30_UTC-20*60)// Mon, 01 Jun 2015 10:10:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumCantBeginAt_11() {
		let date = NSDate(timeIntervalSince1970: k10_30_UTC+30*60)// Mon, 01 Jun 2015 11:00:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssertFalse(taskType == TaskType.Scrum, "Pass")
	}
	
	
	func testLunchBeginAt_12() {
		let date = NSDate(timeIntervalSince1970: k12_30_UTC-30*60)// Mon, 01 Jun 2015 12:00:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Lunch, "Pass")
	}
	
	func testLunchBeginAt_12_30() {
		let date = NSDate(timeIntervalSince1970: k12_30_UTC)// Mon, 01 Jun 2015 12:30:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Lunch, "Pass")
	}
	
	func testLunchBeginAt_14() {
		let date = NSDate(timeIntervalSince1970: k13_UTC+60*60)// Mon, 01 Jun 2015 14:00:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Lunch, "Pass")
	}
	
	func testLunchTooLate() {
		let date = NSDate(timeIntervalSince1970: k13_UTC+120*60)// Mon, 01 Jun 2015 15:00:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssertFalse(taskType == TaskType.Lunch, "Pass")
	}
	
}
