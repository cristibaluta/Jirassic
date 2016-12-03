//
//  TaskSuggestionPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation

protocol TaskSuggestionPresenterInput: class {
    func setup (startSleepDate: Date?, endSleepDate: Date?)
    func selectSegment (atIndex index: Int)
    func save (selectedSegment: Int, notes: String, startSleepDate: Date?, endSleepDate: Date?)
}

protocol TaskSuggestionPresenterOutput: class {
    func setTaskType (_ taskType: TaskSubtype)
    func setHeadnotes (_ notes: String)
    func setNotes (_ notes: String)
}

class TaskSuggestionPresenter {
    
    weak var userInterface: TaskSuggestionPresenterOutput?
    
    fileprivate func taskSubtype (forIndex index: Int) -> TaskSubtype {
        
        switch index {
            case 0: return .scrumEnd
            case 1: return .meetingEnd
            case 2: return .lunchEnd
            case 3: return .napEnd
            case 4: return .learningEnd
            default: return .issueEnd
        }
    }
}

extension TaskSuggestionPresenter: TaskSuggestionPresenterInput {
    
    func setup (startSleepDate: Date?, endSleepDate: Date?) {
        
//        let subtype = TaskSubtype.meetingEnd
        var time = ""
        if let startDate = startSleepDate {
            time += startDate.HHmm() + "-"
        }
        time += endSleepDate!.HHmm()
        userInterface!.setHeadnotes(time)
    }
    
    func selectSegment (atIndex index: Int) {
        
        let type = taskSubtype(forIndex: index)
        userInterface!.setNotes(type.defaultNotes)
    }
    
    func save (selectedSegment: Int, notes: String, startSleepDate: Date?, endSleepDate: Date?) {
        
        let type = taskSubtype(forIndex: selectedSegment)
        
        var task = Task(subtype: type)
        task.notes = notes
        task.taskNumber = type.defaultTaskNumber
        task.startDate = startSleepDate
        task.endDate = endSleepDate!
        
        let saveInteractor = TaskInteractor(repository: localRepository)
        saveInteractor.saveTask(task)
    }
}
