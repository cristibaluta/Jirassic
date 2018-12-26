//
//  RemoveDuplicate.swift
//  Jirassic
//
//  Created by Cristian Baluta on 26/12/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

/// Removes the later start day
class RemoveDuplicate: RepositoryInteractor {
    
    let date: Date
    
    init(repository: Repository, remoteRepository: Repository?, date: Date) {
        self.date = date
        super.init(repository: repository, remoteRepository: remoteRepository)
    }
    
    func execute() {
        let predicate = NSPredicate(format: "taskType == %i", TaskType.startDay.rawValue)
        
        repository.queryTasks(startDate: date.startOfDay(), endDate: date.endOfDay(), predicate: predicate, completion: { [weak self] (tasks, error) in
            
            guard let _self = self else {
                return
            }
            guard tasks.count > 1 else {
                return
            }
            let taskInteractor = TaskInteractor(repository: _self.repository, remoteRepository: _self.remoteRepository)
            for i in 1..<tasks.count {
                taskInteractor.deleteTask(tasks[i])
            }
        })
    }
}
