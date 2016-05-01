//
//  ReadTasks.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadTasksInteractor: RepositoryInteractor {
	
    func tasksAtPage (page: Int, completion: ([Task]) -> Void) {
        
        data.queryTasks(page, completion: { (tasks, error) in
            completion(tasks)
            
            remoteRepository.queryTasks(page, completion: { (tasks, error) in
                
            })
        })
    }
    
    func tasksInDay (date: NSDate) -> [Task] {
        
        let filteredData = data.queryTasksInDay(date)
        
        return filteredData
    }
}
