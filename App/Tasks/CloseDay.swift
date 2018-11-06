//
//  CloseDay.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/11/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class CloseDay {
    
    func close (with tasks: [Task]) {
        
        guard tasks.count > 1 else {
            return
        }
        let writer = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        
        // Find if the day ended already
        let endDayTask: Task? = tasks.filter({$0.taskType == .endDay}).first
        if endDayTask == nil {
            let endDayDate = tasks.last?.endDate ?? Date()
            let endDayTask = Task(endDate: endDayDate, type: .endDay)
            writer.saveTask(endDayTask, allowSyncing: true) { (savedTask) in
                
            }
        }
        
        for task in tasks {
            writer.saveTask(task, allowSyncing: true, completion: { task in })
        }
    }
}
