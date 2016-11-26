//
//  ComputerWakeUpInteractorTests.swift
//  Jirassic
//
//  Created by Cristian Baluta on 26/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

class ComputerWakeUpInteractorMock: ComputerWakeUpInteractor {
    var log_called = false
    var taskType_received: TaskType?
    override func log (taskType: TaskType) {
        log_called = true
        taskType_received = taskType
    }
}

class ComputerWakeUpInteractorTests: XCTestCase {
    
    func testScrum() {
        
        let repository = InMemoryCoreDataRepository()
        
        let task = Task(dateEnd: Date(hour: 9, minute: 0), type: .startDay)
        let saveInteractor = TaskInteractor(data: repository)
        saveInteractor.saveTask(task)
        
        let interactor = ComputerWakeUpInteractorMock(data: repository)
        
        interactor.runWithLastSleepDate(Date(hour: 10, minute: 30))
        XCTAssert(interactor.log_called)
        XCTAssert(interactor.taskType_received == .scrum)
        
        interactor.log_called = false
        interactor.runWithLastSleepDate(Date(hour: 12, minute: 45))
        XCTAssert(interactor.log_called)
        XCTAssert(interactor.taskType_received == .lunch)
    }
}
