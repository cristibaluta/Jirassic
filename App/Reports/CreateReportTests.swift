//
//  CreateReportTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic

class CreateReportTests: XCTestCase {
    
	var tasks = [Task]()
	let kLunchLength = Double(2760)//46min ~ 45min
	
    override func setUp() {
        super.setUp()
        
        let t0 = Task(dateEnd: Date(year: 2015, month: 6, day: 1, hour: 9, minute: 22), type: TaskType.startDay)

		var t1 = Task()
		t1.endDate = Date(year: 2015, month: 6, day: 1, hour: 9, minute: 45)
        t1.taskNumber = "IOS-1"
        t1.notes = "Note 1"

		var t1_1 = Task()
        t1_1.endDate = Date(year: 2015, month: 6, day: 1, hour: 11, minute: 5)
        t1_1.taskNumber = "IOS-2"
        t1_1.notes = "Note 2"

		var t1_lunch = Task()
		t1_lunch.endDate = Date(year: 2015, month: 6, day: 1, hour: 11, minute: 51)
        t1_lunch.taskType = NSNumber(value: TaskType.lunch.rawValue)
		
		var t1_2 = Task()
        t1_2.endDate = Date(year: 2015, month: 6, day: 1, hour: 12, minute: 30)
        t1_2.taskNumber = "IOS-3"
        t1_2.notes = "Note 3"
		
		var t1_3 = Task()
        t1_3.endDate = Date(year: 2015, month: 6, day: 1, hour: 14, minute: 50)
        t1_3.taskNumber = "IOS-1"
        t1_3.notes = "Note 4"
		
		var t1_4 = Task()
        t1_4.endDate = Date(year: 2015, month: 6, day: 1, hour: 16, minute: 10)
        t1_4.taskNumber = "IOS-4"
        t1_4.notes = "Note 5"
		
		var t2 = Task()
        t2.endDate = Date(year: 2015, month: 6, day: 1, hour: 18, minute: 0)
        t2.taskNumber = "IOS-4"
        t2.notes = "Note 6"
		
		tasks = [t0, t1, t1_1, t1_lunch, t1_2, t1_3, t1_4, t2]
    }
    
    override func tearDown() {
		tasks = []
        super.tearDown()
    }

    func testRoundLessThan8HoursOfWork() {
		
		let report = CreateReport(tasks: self.tasks)
		let reports = report.reports()
        
        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
		
		XCTAssert(duration == 8.0.hoursToSec)
    }
    
    func testGroupByTaskNumber() {
        
        let report = CreateReport(tasks: self.tasks)
        let reports = report.reports()
        
        XCTAssert(reports.count == 4, "There should be only 4 unique task numbers. Lunch is ignored")
    }
	
	func testRoundMoreThan8HoursOfWork() {
		
		var t3 = Task()
		t3.endDate = Date(year: 2015, month: 6, day: 1, hour: 19, minute: 30)
		var tasks = self.tasks
		tasks.append(t3)
        
		let report = CreateReport(tasks: tasks)
        let reports = report.reports()
		
        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
        
        XCTAssert(duration == 8.0.hoursToSec)
    }
}
