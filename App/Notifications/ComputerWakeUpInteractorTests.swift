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
    override func save (task: Task) {
        log_called = true
        taskType_received = task.taskType
    }
}

class ComputerWakeUpInteractorTests: XCTestCase {
    
    func testScrumAndLunch() {
        
        let repository = InMemoryCoreDataRepository()
        let settings = Settings(enableBackup: false, settingsTracking: SettingsTracking(autotrack: true, autotrackingMode: TrackingMode.auto, trackLunch: true, trackScrum: true, trackMeetings: true, trackStartOfDay: true, startOfDayTime: Date(hour: 9, minute: 0), endOfDayTime: Date(hour: 17, minute: 0), lunchTime: Date(hour: 12, minute: 30), scrumTime: Date(hour: 10, minute: 30), minSleepDuration: 10), settingsBrowser: SettingsBrowser(trackCodeReviews: true, trackWastedTime: true, minCodeRevDuration: 5, codeRevLink: "", minWasteDuration: 5, wasteLinks: []))
        
        // Insert start of the day otherwise scrum can't be detected
        let task = Task(endDate: Date(hour: 9, minute: 0), type: .startDay)
        let saveInteractor = TaskInteractor(repository: repository, remoteRepository: nil)
        saveInteractor.saveTask(task, allowSyncing: false, completion: { task in })
        
        let interactor = ComputerWakeUpInteractorMock(repository: repository, remoteRepository: nil, settings: settings)
        
        interactor.runWith(lastSleepDate: Date(hour: 10, minute: 30), currentDate: Date(hour: 10, minute: 55))
        XCTAssert(interactor.log_called)
        XCTAssert(interactor.taskType_received == .scrum)
        
        interactor.log_called = false
        interactor.runWith(lastSleepDate: Date(hour: 12, minute: 45), currentDate: Date(hour: 13, minute: 30))
        XCTAssert(interactor.log_called)
        XCTAssert(interactor.taskType_received == .lunch)
    }
}
