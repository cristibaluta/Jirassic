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
    
    let report = CreateReport()
	var tasks = [Task]()
	let kLunchLength = Double(2760)//46min ~ 45min
	
    override func setUp() {
        super.setUp()
        
        let t0 = Task(dateEnd: Date(year: 2015, month: 6, day: 1, hour: 9, minute: 22), type: TaskType.startDay)

		var t1 = Task()
		t1.endDate = Date(year: 2015, month: 6, day: 1, hour: 9, minute: 45)
        t1.taskNumber = "coderev"
        t1.notes = "Code reviews"
        
        var scrum = Task(dateEnd: Date(year: 2015, month: 6, day: 1, hour: 10, minute: 47), type: TaskType.scrum)
        scrum.startDate = Date(year: 2015, month: 6, day: 1, hour: 10, minute: 30)
        
        var lunch = Task(dateEnd: Date(year: 2015, month: 6, day: 1, hour: 13, minute: 51), type: TaskType.lunch)
        lunch.startDate = Date(year: 2015, month: 6, day: 1, hour: 12, minute: 45)
        
        // t1_1 begins before the scrum but ends after the scrum. Subtract the scrum duration
		var t1_1 = Task()
        t1_1.endDate = Date(year: 2015, month: 6, day: 1, hour: 14, minute: 5)
        t1_1.taskNumber = "IOS-2"
        t1_1.notes = "Note 2"

		var t1_2 = Task()
        t1_2.endDate = Date(year: 2015, month: 6, day: 1, hour: 14, minute: 50)
        t1_2.taskNumber = "IOS-3"
        t1_2.notes = "Note 3"
		
		var t1_3 = Task()
        t1_3.endDate = Date(year: 2015, month: 6, day: 1, hour: 15, minute: 6)
        t1_3.taskNumber = "coderev"
        t1_3.notes = "Codereviews"
		
		var t2 = Task()
        t2.endDate = Date(year: 2015, month: 6, day: 1, hour: 18, minute: 0)
        t2.taskNumber = "IOS-4"
        t2.notes = "Note 6"
		
		tasks = [t0, t1, scrum, lunch, t1_1, t1_2, t1_3, t2]
    }
    
    override func tearDown() {
		tasks = []
        super.tearDown()
    }
    
    func testRoundLessThan8HoursOfWork() {
		
		let reports = report.reports(fromTasks: tasks)
        
        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
		
		XCTAssert(duration == 8.0.hoursToSec)
    }
    
    func testGroupByTaskNumber() {
        
        let reports = report.reports(fromTasks: tasks)
        print(reports)
        XCTAssert(reports.count == 5, "There should be only 5 unique task numbers. Lunch is ignored")
       // XCTAssert(reports[0].duration = )
       // XCTAssert(reports[0].duration = )
    }
	
	func testRoundMoreThan8HoursOfWork() {
		
		var t3 = Task()
		t3.endDate = Date(year: 2015, month: 6, day: 1, hour: 19, minute: 30)
		var tasks = self.tasks
		tasks.append(t3)
        
        let reports = report.reports(fromTasks: tasks)
		
        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
        
        XCTAssert(duration == 8.0.hoursToSec)
    }
}
