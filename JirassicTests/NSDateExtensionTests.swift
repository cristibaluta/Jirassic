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
		let components = gregorian!.components(ymdhmsUnitFlags, fromDate:fstOfMay2015)
		
		XCTAssertTrue(components.year == 2015, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.month == 5, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.day == 1, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.hour == 0, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.minute == 0, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.second == 0, "Test failed, check firstDateThisMonth method")
    }
	
	func testRoundDateUpToNearestQuarter() {
		
		var date = NSDate(timeIntervalSince1970: 1433164086) // Mon, 01 Jun 2015 13:08:06 GMT
		XCTAssertTrue(date.roundUp().timeIntervalSince1970 == 1433164500,
			"Date should be Mon, 01 Jun 2015 13:15:00 GMT")
		
		date = NSDate(timeIntervalSince1970: 1433164626) // Mon, 01 Jun 2015 13:17:06 GMT
		XCTAssertTrue(date.roundUp().timeIntervalSince1970 == 1433164500,
			"Date should be Mon, 01 Jun 2015 13:15:00 GMT")
		
		date = NSDate(timeIntervalSince1970: 1433165280) // Mon, 01 Jun 2015 13:28:00 GMT
		XCTAssertTrue(date.roundUp().timeIntervalSince1970 == 1433165400,
			"Date should be Mon, 01 Jun 2015 13:30:00 GMT")
		
		date = NSDate(timeIntervalSince1970: 1433166240) // Mon, 01 Jun 2015 13:44:00 GMT
		XCTAssertTrue(date.roundUp().timeIntervalSince1970 == 1433166300,
			"Date should be Mon, 01 Jun 2015 13:45:00 GMT")
		
		date = NSDate(timeIntervalSince1970: 1433166846) // Mon, 01 Jun 2015 13:54:06 GMT
		XCTAssertTrue(date.roundUp().timeIntervalSince1970 == 1433167200,
			"Date should be Mon, 01 Jun 2015 14:00:00 GMT")
	}
	
	func testSecondsToPercent() {
		let date = NSDate()
		XCTAssertTrue(date.secondsToPercentTime(1800) == 0.5, "")
		XCTAssertTrue(date.secondsToPercentTime(3600) == 1, "")
		XCTAssertTrue(date.secondsToPercentTime(3600+1800) == 1.5, "")
		XCTAssertTrue(date.secondsToPercentTime(7200) == 2, "")
	}
}
