//
//  ReadTasks.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadTasksInteractor: RepositoryInteractor {
	
    // Return a list of tasks sorted by date
    func tasksInDay (_ date: Date) -> [Task] {
        return self.repository.queryTasks(startDate: date.startOfDay(), endDate: date.endOfDay(), predicate: nil)
    }

    // Return a list of tasks sorted by date
    func tasksInMonth (_ date: Date) -> [Task] {
        return self.repository.queryTasks(startDate: date.startOfMonth(), endDate: date.endOfMonth(), predicate: nil)
    }

    // Return a list of tasks sorted by date
    func tasks (between dateStart: Date, and dateEnd: Date) -> [Task] {
        return self.repository.queryTasks(startDate: dateStart, endDate: dateEnd, predicate: nil)
    }
}
