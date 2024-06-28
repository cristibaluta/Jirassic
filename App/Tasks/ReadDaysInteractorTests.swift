//
//  ReadDaysInteractorTests.swift
//  Jirassic
//
//  Created by Cristian Baluta on 23/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic_no_cloud

class ReadDaysInteractorTests: XCTestCase {
    
    func testGivenMultipleStartDayTasksInADay_CreateASingleDayObjectForThem() {

        let repository = InMemoryCoreDataRepository()
        remoteRepository = nil
        
        let task1 = Task(endDate: Date(year: 2017, month: 5, day: 23, hour: 23, minute: 50), type: TaskType.startDay)
        repository.saveTask(task1, completion: { task in })
        let task2 = Task(endDate: Date(year: 2017, month: 5, day: 24, hour: 0, minute: 30), type: TaskType.startDay)
        repository.saveTask(task2, completion: { task in })
        let task3 = Task(endDate: Date(year: 2017, month: 5, day: 24, hour: 10, minute: 0), type: TaskType.startDay)
        repository.saveTask(task3, completion: { task in })
        
        let interactor = ReadDaysInteractor(repository: repository, remoteRepository: nil)
        // This is synchronous query
        interactor.queryAll { weeks in
            XCTAssertTrue(weeks.first!.days.count == 2)
        }
    }

}
