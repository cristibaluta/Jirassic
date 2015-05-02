//
//  DateTests.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import XCTest

class DateTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testFirstDayThisMonth() {
		let sndOfMay2015 = NSDate(timeIntervalSince1970: 1430589737)
		let fstOfMay2015 = sndOfMay2015.firstDayThisMonth()
		
		let unitFlags: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear |
			NSCalendarUnit.CalendarUnitMonth |
			NSCalendarUnit.CalendarUnitDay |
			NSCalendarUnit.CalendarUnitHour |
			NSCalendarUnit.CalendarUnitMinute |
			NSCalendarUnit.CalendarUnitSecond
		let components = NSCalendar.currentCalendar().components(unitFlags, fromDate:fstOfMay2015)
		
		XCTAssertTrue(components.year == 2015, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.month == 5, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.day == 1, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.hour == 0, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.minute == 0, "Test failed, check firstDateThisMonth method")
		XCTAssertTrue(components.second == 0, "Test failed, check firstDateThisMonth method")
    }
}
