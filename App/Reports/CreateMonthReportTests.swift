//
//  CreateMonthReportTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 09/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

class CreateMonthReportTests: XCTestCase {

    let report = CreateMonthReport()
    var tasks = [Task]()
    let kLunchLength = Double(2760)//46min ~ 45min
    let targetHoursInDay = 8.0.hoursToSec
    
    override func setUp() {

        // day 1
        let str1 = "|10.10||||1;" +
            "|10.25|Code reviews part 1|coderev||8;" +
            "10.30|10.47||||2;" +
            "12.45|13.51||||3;" +
            "|14.5|Note 1|TASK-1||0;" +
            "|14.50|Note 2|TASK-2||0;" +
            "16.10|16.36|Some meeting|meeting||4;" +
            "|18.0|Note 3|TASK-3||0;" +
            "|18.0||||9"
        tasks = buildTasks(str1, date: "2018.10.10")
        
        // day 2
        let str2 = "|9.20||||1;" +
            "|10.25|Code reviews part 1|coderev||8;" +
            "10.30|10.55||||2;" +
            "12.45|13.51||||3;" +
            "|14.5|Note 1|TASK-1||0;" +
            "|14.50|Note 4|TASK-4||0;" +
            "|17.30|Note 5|TASK-5||0;" +
            "|17.30||||9"
        tasks += buildTasks(str2, date: "2018.10.11")
    }

    override func tearDown() {
        tasks = []
        super.tearDown()
    }

    func testGroupByTaskNumber() {

        let reports = report.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
        var totalDuration = 0.0
        XCTAssert(reports.count == 8, "There should be only 8 unique task numbers. Lunch and waste are ignored")
        for i1 in 0..<reports.count {
            totalDuration += reports[i1].duration
            for i2 in 0..<reports.count {
                if i1 != i2 {
                    XCTAssertFalse(reports[i1].taskNumber == reports[i2].taskNumber, "Duplicate taskNumber found, they should be unique")
                }
            }
        }
        XCTAssert(totalDuration == targetHoursInDay*2, "Duration should be 16 hours")
    }
}
