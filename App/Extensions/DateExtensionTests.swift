//
//  DateTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic_no_cloud

class DateTests: XCTestCase {
    
    func testDateByKeepingTime() {
        
        let d1 = Date()
        let d2 = Date(year: 2016, month: 5, day: 5, hour: 11, minute: 30)
        let d3 = d2.dateByKeepingTime()
        let components1 = gregorian.dateComponents(ymdhmsUnitFlags, from: d1)
        let components2 = gregorian.dateComponents(ymdhmsUnitFlags, from: d2)
        let components3 = gregorian.dateComponents(ymdhmsUnitFlags, from: d3)
        
        XCTAssertTrue(components1.year == components3.year, "Should keep the ymd from current date d1")
        XCTAssertTrue(components1.month == components3.month)
        XCTAssertTrue(components1.day == components3.day)
        XCTAssertTrue(components2.hour == components3.hour, "Should keep the hm from custom date d2")
        XCTAssertTrue(components2.minute == components3.minute)
    }
    
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
		XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 12)) == .orderedSame, "")
		
		date = Date(hour: 13, minute: 17)
		XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 18)) == .orderedSame, "")
		
		date = Date(hour: 13, minute: 28)
		XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 30)) == .orderedSame, "")
        
        date = Date(hour: 13, minute: 31)
        XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 36)) == .orderedSame, "")
        
		date = Date(hour: 13, minute: 44)
		XCTAssertTrue(date.round().compare(Date(hour: 13, minute: 48)) == .orderedSame, "")
		
		date = Date(hour: 13, minute: 55)
		XCTAssertTrue(date.round().compare(Date(hour: 14, minute: 0)) == .orderedSame, "")
	}
	
	func testWeek() {
		let date = Date(year: 2016, month: 1, day: 9, hour: 10, minute: 0)
		let weekBounds = date.weekBounds()
		XCTAssertTrue(weekBounds.0.compare(Date(year: 2016, month: 1, day: 4, hour: 0, minute: 0)) == .orderedSame, "")
		XCTAssertTrue(weekBounds.1.compare(Date(year: 2016, month: 1, day: 10, hour: 23, minute: 59, second: 59)) == .orderedSame, "")
	}
    
    func testIsSameDay() {
        let date1 = Date(year: 2016, month: 1, day: 9, hour: 23, minute: 50)
        let date2 = Date(year: 2016, month: 1, day: 10, hour: 0, minute: 30)
        XCTAssertFalse(date1.isSameDayAs(date2))
    }
    
    func testIsAlmostSameHour() {
        var date1 = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 00)
        var date2 = Date(year: 2016, month: 1, day: 9, hour: 11, minute: 50)
        XCTAssert(date1.isAlmostSameHourAs(date2))
        
        date1 = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 00)
        date2 = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 10)
        XCTAssert(date1.isAlmostSameHourAs(date2))
        
        date1 = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 00)
        date2 = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 11)
        XCTAssertFalse(date1.isAlmostSameHourAs(date2))
        
        date1 = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 00)
        date2 = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 1)
        XCTAssert(date1.isAlmostSameHourAs(date2, devianceSeconds: 60.0))
    }

    func testRoundTo6() {
        let date = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 14)
        let roundedDate = date.round()
        let components = gregorian.dateComponents(ymdhmsUnitFlags, from: roundedDate)

        XCTAssertTrue(components.hour == 12)
        XCTAssertTrue(components.minute == 18)
    }

    func testRoundTo30() {
        let date = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 8)
        let roundedDate = date.round(minutesPrecision: 30)
        let components = gregorian.dateComponents(ymdhmsUnitFlags, from: roundedDate)

        XCTAssertTrue(components.hour == 12)
        XCTAssertTrue(components.minute == 30)
    }

    func testRoundToNextHour() {
        let date = Date(year: 2016, month: 1, day: 9, hour: 12, minute: 48)
        let roundedDate = date.round(minutesPrecision: 30)
        let components = gregorian.dateComponents(ymdhmsUnitFlags, from: roundedDate)

        XCTAssertTrue(components.hour == 13)
        XCTAssertTrue(components.minute == 0)
    }
}
