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
		let date = NSDate(timeIntervalSince1970: 1433154600)// Mon, 01 Jun 2015 10:30:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumBeginAt10_40() {
		let date = NSDate(timeIntervalSince1970: 1433154600+10*60)// Mon, 01 Jun 2015 10:40:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumBeginAt10_20() {
		let date = NSDate(timeIntervalSince1970: 1433154600-10*60)// Mon, 01 Jun 2015 10:20:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssert(taskType == TaskType.Scrum, "Pass")
	}
	
	func testScrumBeginAt11() {
		let date = NSDate(timeIntervalSince1970: 1433154600+30*60)// Mon, 01 Jun 2015 11:00:00 GMT
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(date)
		XCTAssertFalse(taskType == TaskType.Scrum, "Pass")
	}
}
