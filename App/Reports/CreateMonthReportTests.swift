//
//  CreateMonthReportTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 09/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest

class CreateMonthReportTests: XCTestCase {

    let report = CreateMonthReport()
    var tasks = [Task]()
    let kLunchLength = Double(2760)//46min ~ 45min
    let targetHoursInDay = 8.0.hoursToSec
    
    override func setUp() {

        let start1 = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 10, minute: 10), type: .startDay)

        var d1_1 = Task()
        d1_1.endDate = Date(year: 2015, month: 6, day: 1, hour: 10, minute: 25)
        d1_1.taskNumber = "coderev"
        d1_1.notes = "Code reviews part 1"

        var scrum1 = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 10, minute: 47), type: .scrum)
        scrum1.startDate = Date(year: 2015, month: 6, day: 1, hour: 10, minute: 30)

        var lunch1 = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 13, minute: 51), type: .lunch)
        lunch1.startDate = Date(year: 2015, month: 6, day: 1, hour: 12, minute: 45)

        var d1_2 = Task()
        d1_2.endDate = Date(year: 2015, month: 6, day: 1, hour: 14, minute: 5)
        d1_2.taskNumber = "TASK-1"
        d1_2.notes = "Note 1"

        var d1_3 = Task()
        d1_3.endDate = Date(year: 2015, month: 6, day: 1, hour: 14, minute: 50)
        d1_3.taskNumber = "TASK-3"
        d1_3.notes = "Note 3"

        var meeting1 = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 16, minute: 36), type: .meeting)
        meeting1.startDate = Date(year: 2015, month: 6, day: 1, hour: 16, minute: 10)

        var d1_4 = Task()
        d1_4.endDate = Date(year: 2015, month: 6, day: 1, hour: 18, minute: 0)
        d1_4.taskNumber = "TASK-4"
        d1_4.notes = "Note 4"

        let end1 = Task(endDate: Date(year: 2015, month: 6, day: 1, hour: 18, minute: 0), type: .endDay)

        tasks = [start1, d1_1, scrum1, lunch1, d1_2, d1_3, meeting1, t2, end1]
    }

    override func tearDown() {
        tasks = []
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
}
