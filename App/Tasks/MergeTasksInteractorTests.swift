//
//  MergeTasksInteractorTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 20/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

class MergeTasksInteractorTests: XCTestCase {

    func testMerge() {
        let tasks = [Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 9, minute: 30, second: 50), type: .issue),
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 13, minute: 10, second: 0), type: .lunch),
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 14, minute: 30, second: 30), type: .gitCommit),
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 16, minute: 30, second: 50), type: .gitCommit)
        ]
        let gitTasks = [Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 14, minute: 30, second: 30), type: .gitCommit),
                        Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 16, minute: 30, second: 50), type: .gitCommit),
                        Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 16, minute: 30, second: 50), type: .gitCommit),// Duplicate provided by git cmd
                        Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 18, minute: 0, second: 0), type: .gitCommit)
        ]
        
        let mergedTasks = MergeTasksInteractor().merge(tasks: tasks, with: gitTasks)
        
        XCTAssert(mergedTasks.count == 5)
        XCTAssert(tasks[0].endDate.compare(mergedTasks[0].endDate) == .orderedSame)
        XCTAssert(tasks[1].endDate.compare(mergedTasks[1].endDate) == .orderedSame)
        XCTAssert(tasks[2].endDate.compare(mergedTasks[2].endDate) == .orderedSame)
        XCTAssert(tasks[3].endDate.compare(mergedTasks[3].endDate) == .orderedSame)
        XCTAssert(gitTasks[2].endDate.compare(mergedTasks[4].endDate) == .orderedSame)
    }
}
