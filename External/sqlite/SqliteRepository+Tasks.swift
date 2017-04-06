//
//  SqliteRepository+Tasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension SqliteRepository: RepositoryTasks {
    
    func queryTasks (_ page: Int, completion: @escaping ([Task], NSError?) -> Void) {
        
        let predicate = "deleted == 0"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        
        let predicate = "datetime(endDate) BETWEEN datetime('\(day.startOfDay().YYYYMMddHHmmss())') AND datetime('\(day.endOfDay().YYYYMMddHHmmss())') AND deleted == 0"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func queryTasksInDay (_ day: Date, completion: @escaping ([Task], NSError?) -> Void) {
        completion(queryTasksInDay(day), nil)
    }
    
    func queryUnsyncedTasks() -> [Task] {
        
        let predicate = "lastModifiedDate is NULL AND deleted == 0"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void) {
        
        let predicate = "deleted == 1"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        completion(tasks)
    }
    
    func queryChangedTasks (sinceDate: Date, completion: @escaping ([Task], NSError?) -> Void) {
        
        let predicate = "datetime(lastModifiedDate) > datetime('\(sinceDate.YYYYMMddHHmmss())') AND deleted == 0"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        completion(tasks, nil)
    }
    
    func deleteTask (_ task: Task, completion: @escaping ((_ success: Bool) -> Void)) {
        
        let stask = staskFromTask(task)
        let deleted = stask.delete()
        //        RCLog("deleted \(deleted)")
        
        completion(deleted)
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task) -> Void)) {
        
        RCLog("save to sqlite \(task)")
        let stask = staskFromTask(task)
        let _ = stask.save()
        completion( taskFromSTask(stask))
    }
}

extension SqliteRepository {
    
    fileprivate func taskFromSTask (_ stask: STask) -> Task {
        
        return Task(lastModifiedDate: stask.lastModifiedDate,
                    startDate: stask.startDate,
                    endDate: stask.endDate!,
                    notes: stask.notes,
                    taskNumber: stask.taskNumber,
                    taskType: TaskType(rawValue: stask.taskType)!,
                    objectId: (local: stask.objectId!, remote: stask.remoteId)
        )
    }
    
    fileprivate func tasksFromSTasks (_ rtasks: [STask]) -> [Task] {
        
        var tasks = [Task]()
        for rtask in rtasks {
            tasks.append( taskFromSTask(rtask) )
        }
        
        return tasks
    }
    
    fileprivate func staskFromTask (_ task: Task) -> STask {
        
        let taskPredicate = "objectId == '\(task.objectId.local)'"
        let tasks: [STask] = queryWithPredicate(taskPredicate, sortingKeyPath: nil)
        var stask: STask? = tasks.first
        if stask == nil {
            stask = STask()
            stask!.objectId = task.objectId.local
        }
        
        return updatedSTask(stask!, withTask: task)
    }
    
    // Update only updatable properties. objectId can't be updated
    fileprivate func updatedSTask (_ stask: STask, withTask task: Task) -> STask {
        
        stask.taskNumber = task.taskNumber
        stask.taskType = task.taskType.rawValue
        stask.notes = task.notes
        stask.startDate = task.startDate
        stask.endDate = task.endDate
        stask.lastModifiedDate = task.lastModifiedDate
        stask.remoteId = task.objectId.remote
        
        return stask
    }
}
