//
//  SqliteRepository+Tasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension SqliteRepository: RepositoryTasks {
    
    func queryTasks (_ page: Int, completion: ([Task], NSError?) -> Void) {
        
        let results: [STask] = queryWithPredicate(nil, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        
        let predicate = "datetime(endDate) BETWEEN datetime('\(day.startOfDay().YYYYMMddHHmmss())') AND datetime('\(day.endOfDay().YYYYMMddHHmmss())')"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func queryUnsyncedTasks() -> [Task] {
        
        let predicate = "lastModifiedDate == NULL"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func deleteTask (_ task: Task, completion: ((_ success: Bool) -> Void)) {
        
        let stask = staskFromTask(task)
        let deleted = stask.delete()
        //        RCLog("deleted \(deleted)")
        
        completion(deleted)
    }
    
    func saveTask (_ task: Task, completion: (_ success: Bool) -> Void) -> Task {
        
        let stask = staskFromTask(task)
        let saved = stask.save()
        //        RCLog("saved \(saved)")
        completion(saved == 1)
        
        return taskFromSTask(stask)
    }
}

extension SqliteRepository {
    
    fileprivate func taskFromSTask (_ rtask: STask) -> Task {
        
        return Task(startDate: rtask.startDate,
                    endDate: rtask.endDate!,
                    notes: rtask.notes,
                    taskNumber: rtask.taskNumber,
                    taskType: TaskType(rawValue: rtask.taskType)!,
                    objectId: rtask.objectId!
        )
    }
    
    fileprivate func tasksFromSTasks (_ rtasks: [STask]) -> [Task] {
        
        var tasks = [Task]()
        for rtask in rtasks {
            tasks.append(self.taskFromSTask(rtask))
        }
        
        return tasks
    }
    
    fileprivate func staskFromTask (_ task: Task) -> STask {
        
        let taskPredicate = "objectId == '\(task.objectId)'"
        let tasks: [STask] = queryWithPredicate(taskPredicate, sortingKeyPath: nil)
        var stask: STask? = tasks.first
        if stask == nil {
            stask = STask()
        }
        if stask!.objectId == nil {
            stask!.objectId = task.objectId
        }
        
        return updatedSTask(stask!, withTask: task)
    }
    
    // Update only updatable properties. objectId can't be updated
    fileprivate func updatedSTask (_ rtask: STask, withTask task: Task) -> STask {
        
        rtask.taskNumber = task.taskNumber
        rtask.taskType = task.taskType.rawValue
        rtask.notes = task.notes
        rtask.startDate = task.startDate
        rtask.endDate = task.endDate
        
        return rtask
    }
}
