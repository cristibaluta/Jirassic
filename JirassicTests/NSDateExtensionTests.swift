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
		
		let sndOfMay2015 = NSDate(timeIntervalSince1970: 1430589737)
		let fstOfMay2015 = sndOfMay2015.firstDayThisMonth()
		let components = gregorian!.components(ymdhmsUnitFlags, fromDate: fstOfMay2015)
		
		XCTAssertTrue(components.year == 2015, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.month == 5, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.day == 1, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.hour == 0, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.minute == 0, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.second == 0, "Test failed, check firstDateThisMonth method")
    }
	
	func testRoundDateUpToNearestQuarter() {
		
		var date = NSDate(hour: 13, minute: 8)
		XCTAssertTrue(date.roundUp().compare(NSDate(hour: 13, minute: 15)) == .OrderedSame, "")
		
		date = NSDate(hour: 13, minute: 17)
		XCTAssertTrue(date.roundUp().compare(NSDate(hour: 13, minute: 15)) == .OrderedSame, "")
		
		date = NSDate(hour: 13, minute: 28)
		XCTAssertTrue(date.roundUp().compare(NSDate(hour: 13, minute: 30)) == .OrderedSame, "")
		
		date = NSDate(hour: 13, minute: 44)
		XCTAssertTrue(date.roundUp().compare(NSDate(hour: 13, minute: 45)) == .OrderedSame, "")
		
		date = NSDate(hour: 13, minute: 54)
		XCTAssertTrue(date.roundUp().compare(NSDate(hour: 14, minute: 0)) == .OrderedSame, "")
	}
	
	func testSecondsToPercent() {
		let date = NSDate()
		XCTAssertTrue(date.secondsToPercentTime(1800) == 0.5, "")
		XCTAssertTrue(date.secondsToPercentTime(3600) == 1, "")
		XCTAssertTrue(date.secondsToPercentTime(3600+1800) == 1.5, "")
		XCTAssertTrue(date.secondsToPercentTime(7200) == 2, "")
	}
}
