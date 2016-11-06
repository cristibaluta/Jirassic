//
//  DateTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic

class DateTests: XCTestCase {
	
    func testFirstDayThisMonth() {
		
		let sndOfMay2015 = Date(timeIntervalSince1970: 1430589737)
		let fstOfMay2015 = sndOfMay2015.startOfMonth()
		let components = gregorian.dateComponents(ymdhmsUnitFlags, from: fstOfMay2015)
		
		XCTAssertTrue(components.year == 2015, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.month == 5, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.day == 1, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.hour == 0, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.minute == 0, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.second == 0, "Test failed, check firstDateThisMonth method")
    }
	
	func testRoundDateUpToNearestQuarter() {
		
		var date = Date(hour: 13, minute: 8)
		XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 15)) == .orderedSame, "")
		
		date = Date(hour: 13, minute: 17)
		XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 15)) == .orderedSame, "")
		
		date = Date(hour: 13, minute: 28)
		XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 30)) == .orderedSame, "")
		
		date = Date(hour: 13, minute: 44)
		XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 45)) == .orderedSame, "")
		
		date = Date(hour: 13, minute: 54)
		XCTAssertTrue(date.round().compare(Date(hour: 14, minute: 0)) == .orderedSame, "")
	}
	
	func testSecondsToPercent() {
		let date = Date()
		XCTAssertTrue(date.secondsToPercentTime(1800) == 0.5, "")
		XCTAssertTrue(date.secondsToPercentTime(3600) == 1, "")
		XCTAssertTrue(date.secondsToPercentTime(3600+1800) == 1.5, "")
		XCTAssertTrue(date.secondsToPercentTime(7200) == 2, "")
	}
	
	func testWeek() {
		let date = Date(year: 2016, month: 1, day: 9, hour: 10, minute: 0)
		let weekBounds = date.weekBounds()
		XCTAssertTrue(weekBounds.0.compare(Date(year: 2016, month: 1, day: 4, hour: 0, minute: 0)) == .orderedSame, "")
		XCTAssertTrue(weekBounds.1.compare(Date(year: 2016, month: 1, day: 10, hour: 23, minute: 59, second: 59)) == .orderedSame, "")
	}
}
