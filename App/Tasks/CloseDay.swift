//
//  CloseDay.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/11/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import RCLog

class CloseDay {
    
    func close (with tasks: [Task]) {
        
        guard tasks.count > 1 else {
            return
        }
        let interactor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        
        // Find if the day ended already
        let endDayTask: Task? = tasks.filter({$0.taskType == .endDay}).first
        // If not, end it now
        if endDayTask == nil {
            let endDayDate = tasks.last?.endDate ?? Date()
            let endDayTask = Task(endDate: endDayDate, type: .endDay)
            interactor.saveTask(endDayTask, allowSyncing: true) { savedTask in }
        }
        // Save to db only the tasks that are not already saved, like git commits and calendar events
        for task in tasks {
            if task.objectId == nil {
                var task = task
                RCLog("Unsaved task found \(task)")
                task.objectId = String.generateId()
                interactor.saveTask(task, allowSyncing: true) { savedTask in }
            }
        }
    }
}
