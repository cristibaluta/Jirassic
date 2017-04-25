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
        
        let predicate = "markedForDeletion == 0"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        
        let predicate = "datetime(endDate) BETWEEN datetime('\(day.startOfDay().YYYYMMddHHmmss())') AND datetime('\(day.endOfDay().YYYYMMddHHmmss())') AND markedForDeletion == 0"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func queryTasksInDay (_ day: Date, completion: @escaping ([Task], NSError?) -> Void) {
        completion(queryTasksInDay(day), nil)
    }
    
    func queryUnsyncedTasks() -> [Task] {
        
        RCLogO("Query tasks since last sync date \(String(describing: UserDefaults.standard.localChangeDate))")
        var sinceDatePredicate = ""
        if let sinceDate = UserDefaults.standard.localChangeDate {
            sinceDatePredicate = " OR datetime(lastModifiedDate) > datetime('\(sinceDate.YYYYMMddHHmmss())')"
        }
        let predicate = "(lastModifiedDate is NULL\(sinceDatePredicate)) AND markedForDeletion == 0"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void) {
        
        let predicate = "markedForDeletion == 1"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        completion(tasks)
    }
    
    func queryUpdates (_ completion: @escaping ([Task], [String], NSError?) -> Void) {
        
        queryDeletedTasks { (deletedTasks) in
            let unsyncedTasks = self.queryUnsyncedTasks()
            let deletedTasksIds = deletedTasks.map{ $0.objectId }
            completion(unsyncedTasks, deletedTasksIds, nil)
        }
    }
    
    func deleteTask (_ task: Task, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
        let stask = staskFromTask(task)
        if permanently {
            completion( stask.delete() )
        } else {
            stask.markedForDeletion = true
            completion( stask.save() == 1 )
        }
    }
    
    func deleteTask (objectId: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
        let taskPredicate = "objectId == '\(objectId)'"
        let tasks: [STask] = queryWithPredicate(taskPredicate, sortingKeyPath: nil)
        if let stask = tasks.first {
            completion( stask.delete() )
        } else {
            completion( false )
        }
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task) -> Void)) {
        
//        RCLog("save to sqlite \(task)")
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
                    taskTitle: stask.taskTitle,
                    taskType: TaskType(rawValue: stask.taskType)!,
                    objectId: stask.objectId!
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
        
        let taskPredicate = "objectId == '\(task.objectId)'"
        let tasks: [STask] = queryWithPredicate(taskPredicate, sortingKeyPath: nil)
        var stask: STask? = tasks.first
        if stask == nil {
            stask = STask()
            stask!.objectId = task.objectId
        }
        
        return updatedSTask(stask!, withTask: task)
    }
    
    // Update only updatable properties. objectId can't be updated
    fileprivate func updatedSTask (_ stask: STask, withTask task: Task) -> STask {
        
        stask.taskNumber = task.taskNumber
        stask.taskType = task.taskType.rawValue
        stask.taskTitle = task.taskTitle
        stask.notes = task.notes
        stask.startDate = task.startDate
        stask.endDate = task.endDate
        stask.lastModifiedDate = task.lastModifiedDate
        
        return stask
    }
}
