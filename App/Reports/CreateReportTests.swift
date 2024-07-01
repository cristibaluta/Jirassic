//
//  CreateReportTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic_no_cloud

func buildTasks(_ str: String, date: String = "2018.10.10") -> [Task] {
    var tasks = [Task]()
    // str format:
    // startDate: Date? | endDate: Date | notes: String? | taskNumber: String? | taskTitle: String? | taskType: TaskType | objectId: String?
    let lines =  str.components(separatedBy: ";")
    for line in lines {
        let comps = line.components(separatedBy: "|")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd.HH.mm"
        let endDate = dateFormatter.date(from: date + "." + comps[1])
        
        var task = Task(endDate: endDate!, type: TaskType(rawValue: Int(comps[5])!)!)
        
        if comps[0] != "" {
            task.startDate = dateFormatter.date(from: date + "." + comps[0])
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
        // objectId
        if comps[6] == "nil" {
            task.objectId = nil
        }
        tasks.append(task)
    }
    return tasks
}

class CreateReportTests: XCTestCase {
    
    let report = CreateReport()
	var tasks = [Task]()
	let kLunchLength = Double(2760)//46min ~ 45min
    let targetSecondsInDay = 8.0.hoursToSec

    override func setUp() {
        super.setUp()
        
        let str = "|10.10||||1|;" +
            "|10.25|Code reviews part 1|coderev||8|;" +
            "10.30|10.47||||2|;" +// scrum
            "12.45|13.51||||3|;" +
            "|14.5|Note 2|APP-2||0|;" +// begins before the scrum but ends after the scrum. Subtract the scrum duration
            "|14.50|Note 3|APP-3||0|;" +
            "|15.6|Code reviews part 2|coderev||8|;" +
            "16.10|16.36||||6|;" +//waste
            "|18.0|Note 6|APP-4||0|;" +
            "|18.0||||9|"// end of day
        tasks = buildTasks(str)
    }
    
    override func tearDown() {
		tasks = []
        super.tearDown()
    }
    
    func testGroupByTaskNumber() {
        
        let reports = report.reports(fromTasks: tasks, targetSeconds: targetSecondsInDay)
        XCTAssert(reports.count == 5, "There should be only 5 unique task numbers. Lunch and waste are ignored")
        for i1 in 0..<reports.count {
            for i2 in 0..<reports.count {
                if i1 != i2 {
                    XCTAssertFalse(reports[i1].taskNumber == reports[i2].taskNumber, "Duplicate taskNumber found, they should be unique")
                }
            }
        }
    }
    
    func testGivenLessThan8HoursOfWork_ThenRoundUpTo8Hours() {

		let reports = report.reports(fromTasks: tasks, targetSeconds: targetSecondsInDay)

        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
		
        XCTAssert(duration == targetSecondsInDay)
    }
    
	func testGivenMoreThan8HoursOfWork_ThenRoundDownTo8Hours() {

		var tasks = self.tasks
        tasks.removeLast()
        tasks += buildTasks("|19.30||||0|")

        let reports = report.reports(fromTasks: tasks, targetSeconds: targetSecondsInDay)

        var duration = 0.0
        for report in reports {
            duration += report.duration
        }
        
        XCTAssert(duration == targetSecondsInDay)
    }
    
    func testGivenMeetings_ThenDoNotRoundTheMeetings() {

        var tasks = self.tasks
        tasks.removeLast()
        tasks += buildTasks("|18.20|Learning time|learning||7|")

        let reports = report.reports(fromTasks: tasks, targetSeconds: targetSecondsInDay)

        XCTAssert(reports.count == 6)
        
        XCTAssert(reports[1].taskNumber == "scrum")
        XCTAssert(reports[1].duration == 18.minToSec)
        
        XCTAssert(reports[5].taskNumber == "learning")
        XCTAssert(reports[5].duration == 16.minToSec)
    }
    
    func testRealSituationWhereDurationCanBeMessedUp() {
        
        let str = "|8.59||||1|;" +
            "10.4|11.10|Meeting 1|meeting||4|;" +
            "11.39|12.22||||3|;" +
            "|13.4|Note 1|APP-3730||0|;" +
            "|13.19|Note 2|APP-3730||0|;" +
            "13.20|13.29|coderev 1|coderev||8|;" +
            "14.13|14.21|coderev 2|coderev||8|;" +
            "16.4|16.7|coderev 3|coderev||8|;" +
            "16.56|16.59|coderev 4|coderev||8|;" +
            "|17.30|Note 3|APP-3730||0|"
        tasks = buildTasks(str)
        
        let reports = report.reports(fromTasks: tasks, targetSeconds: targetSecondsInDay)
        XCTAssert(reports.count == 3, "There should be only 3 unique task numbers. Lunch is ignored")
        XCTAssert(reports[0].duration > 0, "Duration should always greater than 0")
        XCTAssert(reports[1].duration > 0, "Duration should always greater than 0")
        XCTAssert(reports[2].duration > 0, "Duration should always greater than 0")
        var totalDuration = 0.0
        for report in reports {
            totalDuration += report.duration
        }
        XCTAssert(totalDuration == targetSecondsInDay)
    }
    
    func testRealSituation2() {
        
        let str = "|10.00||||1|;" +
            "13.0|13.10|socialmedia|waste||6|;" +
            "|18.45|task 1|APP-3730||0|;" +
            "|18.45||||9|"
        tasks = buildTasks(str)
        
        let reports = report.reports(fromTasks: tasks, targetSeconds: nil)
        XCTAssert(reports.count == 1, "Only one valid task")
        XCTAssert(reports[0].duration == 8 * 3600 + 35 * 60, "8h 35m")
    }

    func testDurations() {

        let str =   "|9.01||||1|;" +
                    "9.12|9.22||||8|;" +// coderev
                    "10.0|10.30||||10|"// calendar
        tasks = buildTasks(str)

        let reports = report.reports(fromTasks: tasks, targetSeconds: 8.hoursToSec)
        XCTAssert(reports.count == 2)
        XCTAssert(reports[0].duration == 8.hoursToSec - 1800, "Code rev should fill the remaining time")
        XCTAssert(reports[1].duration == 1800, "Scrum should be 30min")
    }

    func testRoundingDurations() {

        let str =   "|9.01||||1|;" +
                    "9.12|9.22||||8|;" +// coderev
                    "10.0|10.31||||10|"// calendar
        tasks = buildTasks(str)

        let reports = report.reports(fromTasks: tasks, targetSeconds: 8.hoursToSec)
        XCTAssert(reports.count == 2)
        XCTAssert(reports[0].duration == 8.hoursToSec - 1800, "Code rev should fill the remaining time")
        XCTAssert(reports[1].duration == 1800, "Scrum should be 30min")
    }

    func testGivenSavedAndUnsavedCalendarEventsInASavedDay_IgnoreTheUnsavedEvents() {

        let str = "|9.00||||1|;" +
            "10.0|12.00|saved event1|||10|;" +
            "10.0|10.30|unsaved event1|||10|nil;" +
            "|18.00||||9|"
        tasks = buildTasks(str)

        let reports = report.reports(fromTasks: tasks, targetSeconds: nil)
        XCTAssert(reports.count == 1, "Only one valid task")
        XCTAssert(reports[0].duration == 2.hoursToSec, "2h 00m")
    }

    func testGivenTaskAfterDayEnds_IgnoreIt() {

        let str = "|9.00||||1|;" +
            "|12.0|Note 1|TASK-1||0|;" +
            "|18.00||||9|;" +
            "|19.0|Note 1|TASK-2||0|"
        tasks = buildTasks(str)

        let reports = report.reports(fromTasks: tasks, targetSeconds: nil)
        XCTAssert(reports.count == 1, "Only one valid task")
        XCTAssert(reports[0].duration == 3.hoursToSec, "3h 00m")
    }
}
