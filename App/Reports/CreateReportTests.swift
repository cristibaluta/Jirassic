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
    let targetHoursInDay = 8.0.hoursToSec
	
    override func setUp() {
        super.setUp()
        
        let t0 = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 10, minute: 10), type: .startDay)

		var t1 = Task()
		t1.endDate = Date(year: 2015, month: 6, day: 1, hour: 10, minute: 25)
        t1.taskNumber = "coderev"
        t1.notes = "Code reviews part 1"
        
        var scrum = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 10, minute: 47), type: .scrum)
        scrum.startDate = Date(year: 2015, month: 6, day: 1, hour: 10, minute: 30)
        
        var lunch = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 13, minute: 51), type: .lunch)
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
        t1_3.notes = "Code reviews part 2"
        
        var waste = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 16, minute: 36), type: .waste)
        waste.startDate = Date(year: 2015, month: 6, day: 1, hour: 16, minute: 10)
        
		var t2 = Task()
        t2.endDate = Date(year: 2015, month: 6, day: 1, hour: 18, minute: 0)
        t2.taskNumber = "IOS-4"
        t2.notes = "Note 6"
		
        let tEnd = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 18, minute: 0), type: .endDay)
        
		tasks = [t0, t1, scrum, lunch, t1_1, t1_2, t1_3, waste, t2, tEnd]
    }
    
    override func tearDown() {
		tasks = []
        super.tearDown()
    }
    
    func testGroupByTaskNumber() {
        
        let reports = report.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
        XCTAssert(reports.count == 5, "There should be only 5 unique task numbers. Lunch and waste are ignored")
        for i1 in 0..<reports.count {
            for i2 in 0..<reports.count {
                if i1 != i2 {
                    XCTAssertFalse(reports[i1].taskNumber == reports[i2].taskNumber, "Duplicate taskNumber found, they should be unique")
                }
            }
        }
    }
    
    func testRoundLessThan8HoursOfWork() {
		
		let reports = report.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
        
        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
		
		XCTAssert(duration == targetHoursInDay)
    }
    
	func testRoundMoreThan8HoursOfWork() {
		
		var t3 = Task()
		t3.endDate = Date(year: 2015, month: 6, day: 1, hour: 19, minute: 30)
		var tasks = self.tasks
		tasks.append(t3)
        
        let reports = report.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
		
        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
        
        XCTAssert(duration == targetHoursInDay)
    }
    
    func testDoNotRoundMeetings() {
        
        var t3 = Task()
        t3.endDate = Date(year: 2015, month: 6, day: 1, hour: 18, minute: 20)
        t3.taskNumber = "learning"
        t3.taskType = .learning
        t3.notes = "Learning time"
        let tasks = self.tasks + [t3]
        
        let reports = report.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
        
        XCTAssert(reports.count == 6)
        
        XCTAssert(reports[1].taskNumber == "scrum")
        XCTAssert(reports[1].duration == 18.minToSec)
        
        XCTAssert(reports[5].taskNumber == "learning")
        XCTAssert(reports[5].duration == 18.minToSec)
    }
    
}
