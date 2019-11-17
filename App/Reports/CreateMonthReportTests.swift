//
//  CreateMonthReportTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 09/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic_no_cloud

class CreateMonthReportTests: XCTestCase {

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
            "|18.0||||9"// end day
        tasks = buildTasks(str1, date: "2018.10.10")
        
        // Add a meeting that is outside the start-end, it should be ignored by reports
        tasks += buildTasks("18.30|19.0|Meeting|calendar meeting||10", date: "2018.10.10")
        
        // day 2 - without endDay
        let str2 = "|9.20||||1;" +
            "|10.25|Code reviews part 1|coderev||8;" +
            "10.30|10.55||||2;" +
            "12.45|13.51||||3;" +
            "|14.5|Note 1|TASK-1||0;" +
            "|14.50|Note 4|TASK-4||0;" +
            "|17.30|Note 5|TASK-5||0"
        tasks += buildTasks(str2, date: "2018.10.11")
        
        // day 3 - with endDay
        let str3 = "|10.20||||1;" +
            "|14.5|Note 1|TASK-1||0;" +
            "|18.30||||9"
        tasks += buildTasks(str3, date: "2018.10.12")
    }

    override func tearDown() {
        tasks = []
        super.tearDown()
    }

    func testGroupByTaskNumber() {

        let reports = CreateMonthReport().reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay, roundHours: false)
        var totalDuration = 0.0
        XCTAssert(reports.byDays.count == 3, "There should be only 8 unique task numbers. Lunch and waste are ignored")
        XCTAssert(reports.byTasks.count == 8, "There should be only 8 unique task numbers. Lunch and waste are ignored")
        for i1 in 0..<reports.byTasks.count {
            totalDuration += reports.byTasks[i1].duration
            for i2 in 0..<reports.byTasks.count {
                if i1 != i2 {
                    XCTAssertFalse(reports.byTasks[i1].taskNumber == reports.byTasks[i2].taskNumber, "Duplicate taskNumber found, they should be unique")
                }
            }
        }
        XCTAssert(totalDuration == targetHoursInDay*3, "Duration should be 8*3 hours")
    }
}
