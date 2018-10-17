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
        
        let str = "|10.10||||1;" +
            "|10.25|Code reviews part 1|coderev||8;" +
            "10.30|10.47||||2;" +
            "12.45|13.51||||3;" +
            "|14.5|Note 2|APP-2||0;" +// begins before the scrum but ends after the scrum. Subtract the scrum duration
            "|14.50|Note 3|APP-3||0;" +
            "|15.6|Code reviews part 2|coderev||8;" +
            "16.10|16.36||||6;" +//waste
            "|18.0|Note 6|APP-4||0;" +
            "|18.0||||9"
        tasks = buildTasks(str)
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
		
		var tasks = self.tasks
        tasks.removeLast()
        tasks += buildTasks("|19.30||||0")
        
        let reports = report.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
		
        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
        
        XCTAssert(duration == targetHoursInDay)
    }
    
    func testDoNotRoundMeetings() {
        
        var tasks = self.tasks
        tasks.removeLast()
        tasks += buildTasks("|18.20|Learning time|learning||7")
        
        let reports = report.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
        
        XCTAssert(reports.count == 6)
        
        XCTAssert(reports[1].taskNumber == "scrum")
        XCTAssert(reports[1].duration == 18.minToSec)
        
        XCTAssert(reports[5].taskNumber == "learning")
        XCTAssert(reports[5].duration == 18.minToSec)
    }
    
    func testRealSituationWhereDurationCanBeMessedUp() {
        
        let str = "|8.59||||1;" +
            "10.4|11.10|Meeting 1|meeting||4;" +
            "11.39|12.22||||3;" +
            "|13.4|Note 1|APP-3730||0;" +
            "|13.19|Note 2|APP-3730||0;" +
            "13.20|13.29|coderev 1|coderev||8;" +
            "14.13|14.21|coderev 2|coderev||8;" +
            "16.4|16.7|coderev 3|coderev||8;" +
            "16.56|16.59|coderev 4|coderev||8;" +
            "|17.42|Note 3|APP-3730||0"
        tasks = buildTasks(str)
        
        let reports = report.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
        XCTAssert(reports.count == 3, "There should be only 3 unique task numbers. Lunch is ignored")
        XCTAssert(reports[0].duration > 0, "Duration should always greater than 0")
        XCTAssert(reports[1].duration > 0, "Duration should always greater than 0")
        XCTAssert(reports[2].duration > 0, "Duration should always greater than 0")
        var totalDuration = 0.0
        for report in reports {
            totalDuration += report.duration
        }
        XCTAssert(totalDuration == targetHoursInDay)
    }
    
    private func buildTasks(_ str: String) -> [Task] {
        var tasks = [Task]()
        // startDate: Date? | endDate: Date | notes: String? | taskNumber: String? | taskTitle: String? | taskType: TaskType
        let lines =  str.components(separatedBy: ";")
        for line in lines {
            let comps = line.components(separatedBy: "|")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY.MM.dd.HH.mm"
            let endDate = dateFormatter.date(from: "2018.10.10." + comps[1])
            
            var task = Task(endDate: endDate!, type: TaskType(rawValue: Int(comps[5])!)!)
            
            if comps[0] != "" {
                task.startDate = dateFormatter.date(from: "2018.10.10." + comps[0])
            }
            // notes
            if comps[2] != "" {
                task.notes = comps[2]
            }
            // taskNumber
            if comps[3] != "" {
                task.taskNumber = comps[3]
            }
            // taskTitle
            if comps[4] != "" {
                task.taskTitle = comps[4]
            }
            tasks.append(task)
        }
        return tasks
    }
}
