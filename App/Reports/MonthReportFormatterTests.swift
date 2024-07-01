//
//  CreateMonthReportTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 09/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic_no_cloud

class MonthReportFormatterTests: XCTestCase {

    var tasks = [Task]()
    let kLunchLength = Double(2760)//46min ~ 45min
    let targetSecondsInDay = 8.0.hoursToSec

    override func setUp() {

        // day 1
        let str1 = "|10.10||||1|;" +
            "|10.25|Code reviews 1|coderev||8|;" +
            "10.30|10.47||||2|;" +
            "12.45|13.51||||3|;" +
            "|14.5|Note 1|TASK-1||0|;" +
            "|14.50|Note 1|TASK-2||0|;" +
            "16.10|16.36|Meeting 1|meeting||4|;" +
            "|18.0|Note 1|TASK-3||0|;" +
            "|18.0||||9|"// end day
        tasks = buildTasks(str1, date: "2018.10.10")
        
        // Add a meeting that is outside the start-end, it should be ignored by reports
        tasks += buildTasks("18.30|19.0|Meeting 2|calendar||10|", date: "2018.10.10")

        // day 2 - without endDay
        let str2 = "|9.20||||1|;" +
            "|10.25|Code reviews 1|coderev||8|;" +
            "10.30|10.55||||2|;" +
            "12.45|13.51||||3|;" +
            "|14.5|Note 2|TASK-1||0|;" +
            "|14.50|Note 1|TASK-4||0|;" +
            "|17.30|Note 1|TASK-5||0|"
        tasks += buildTasks(str2, date: "2018.10.11")

        // day 3 - with no task
        let str3 = "|9.0||||1|;" +
            "10.30|10.55||||2|"
        tasks += buildTasks(str3, date: "2018.10.12")

        // day 4 - with no task
        let str4 = "|9.20||||1|;" +
            "10.0|11.00||||2|"
        tasks += buildTasks(str4, date: "2018.10.13")

        // day 5 - with endDay
        let str5 = "|10.20||||1|;" +
            "|14.5|Note 3|TASK-1||0|;" +
            "|18.30||||9|"
        tasks += buildTasks(str5, date: "2018.10.14")
    }

    override func tearDown() {
        tasks = []
        super.tearDown()
    }

    func testGivenTasksInTheMonth_ThenGroupThemByTaskNumber() {

        let reports = MonthReportFormatter().reports(fromTasks: tasks, targetSecondsInDay: targetSecondsInDay)
        
        XCTAssert(reports.byDays.count == 5, "There should be only 5 days")
        XCTAssert(reports.byTasks.count == 8, "There should be only 9 unique task numbers. Lunch and waste are ignored")

        var totalDuration = 0.0
        for day in reports.byDays {
            for report in day {
                totalDuration += report.duration
            }
        }
        XCTAssert(totalDuration == targetSecondsInDay*5, "Duration should be 8*3 hours")

        totalDuration = 0.0
        for i in 0..<reports.byTasks.count {
            totalDuration += reports.byTasks[i].duration
            for j in 0..<reports.byTasks.count {
                if i != j {
                    XCTAssertFalse(reports.byTasks[i].taskNumber == reports.byTasks[j].taskNumber,
                                   "Duplicate taskNumber found, they should be unique")
                }
            }
            XCTAssertFalse(reports.byTasks[i].taskNumber == "calendar",
                           "This event shouldn't be in the reports since it was after the endDay")
        }
        XCTAssert(totalDuration == targetSecondsInDay*5, "Duration should be 8*3 hours")
    }
}
