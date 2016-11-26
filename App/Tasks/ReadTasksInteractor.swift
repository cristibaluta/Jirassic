//
//  ReadTasks.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadTasksInteractor: RepositoryInteractor {
	
    func tasksAtPage (_ page: Int, completion: @escaping ([Task]) -> Void) {
        
        self.repository.queryTasks(page, completion: { (tasks, error) in
            completion(tasks)
            
            remoteRepository?.queryTasks(page, completion: { (tasks, error) in
                
            })
        })
    }
    
    // Return a list of tasks sorted by date
    func tasksInDay (_ date: Date) -> [Task] {
        
        return self.repository.queryTasksInDay(date)
    }
}
