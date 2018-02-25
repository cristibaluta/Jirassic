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
    func selectSegment (atIndex index: Int)
    func setTime (_ notes: String)
    func setNotes (_ notes: String)
    func hideTaskTypes()
}

class TaskSuggestionPresenter {
    
    weak var userInterface: TaskSuggestionPresenterOutput?
    fileprivate var isStartOfDay = false
    fileprivate let startWorkText = "Good morning, ready to start work?"
    
    fileprivate func taskSubtype (forIndex index: Int) -> TaskSubtype {
        
        switch index {
            case 0: return .scrumEnd
            case 1: return .meetingEnd
            case 2: return .lunchEnd
            case 3: return .wasteEnd
            case 4: return .learningEnd
            default: return .issueEnd
        }
    }
    
    fileprivate func selectedSegment (forTaskType taskType: TaskType) -> Int {
        
        switch taskType {
        case .scrum: return 0
        case .meeting: return 1
        case .lunch: return 2
        case .waste: return 3
        case .learning: return 4
        default: return -1
        }
    }
}

extension TaskSuggestionPresenter: TaskSuggestionPresenterInput {
    
    func setup (startSleepDate: Date?, endSleepDate: Date?) {
        
        var time = ""
        if let startDate = startSleepDate {
            time += "Away between \(startDate.HHmm()) - "
        }
        time += endSleepDate!.HHmm()
        userInterface!.setTime(time)
        
        if let startDate = startSleepDate {
            let interactor = ComputerWakeUpInteractor(repository: localRepository)
            if let type = interactor.estimationForDate(startDate, currentDate: Date()) {
                if type == .startDay {
                    isStartOfDay = true
                    userInterface!.setNotes(startWorkText)
                    userInterface!.hideTaskTypes()
                } else {
                    let index = selectedSegment(forTaskType: type)
                    selectSegment(atIndex: index)
                }
            }
        } else {
            isStartOfDay = true
            userInterface!.setNotes(startWorkText)
            userInterface!.hideTaskTypes()
        }
    }
    
    func selectSegment (atIndex index: Int) {
        
        let type = taskSubtype(forIndex: index)
        userInterface!.setNotes(type.defaultNotes)
        userInterface!.selectSegment(atIndex: index)
    }
    
    func save (selectedSegment: Int, notes: String, startSleepDate: Date?, endSleepDate: Date?) {
        
        var task: Task
        
        if isStartOfDay {
            task = Task(endDate: endSleepDate!, type: TaskType.startDay)
        } else {
            let type = taskSubtype(forIndex: selectedSegment)
            task = Task(subtype: type)
            task.notes = notes
            task.taskNumber = type.defaultTaskNumber
            task.startDate = startSleepDate
            task.endDate = endSleepDate!
        }
        
        let saveInteractor = TaskInteractor(repository: localRepository)
        saveInteractor.saveTask(task, allowSyncing: true, completion: { savedTask in
            
        })
        if task.taskType == .startDay {
            ModuleHookup().insert(task: task)
        }
    }
}
