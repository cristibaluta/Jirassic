//
//  ReadTasks.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadTasksInteractor: RepositoryInteractor {
	
    func tasksInDay (date: NSDate) -> [Task] {
        
        let filteredData = data.queryTasksInDay(date)
        
        return filteredData
    }
}
