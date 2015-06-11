//
//  ScrumEstimationTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 11/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest

class ScrumEstimationTests: XCTestCase {
	
	override func setUp() {
		super.setUp()
	}
	
	override func tearDown() {
		super.tearDown()
	}
	
	func testScrumBegin() {
		let estimator = Estimator()
		let taskType = estimator.taskAroundDate(NSDate())
		
	}
}
