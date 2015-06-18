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
	
	func testScrumBegin() {
		let estimator = TaskTypeEstimator()
		let taskType = estimator.taskTypeAroundDate(NSDate())
		
	}
}
