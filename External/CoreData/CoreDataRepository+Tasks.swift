//
//  CoreDataRepository+Tasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataRepository: RepositoryTasks {
    
    func queryTasks (_ page: Int, completion: @escaping ([Task], NSError?) -> Void) {
        
        let sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        let results: [CTask] = queryWithPredicate(nil, sortDescriptors: sortDescriptors)
        let tasks = tasksFromCTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "endDate >= %@ AND endDate <= %@", day.startOfDay() as CVarArg, day.endOfDay() as CVarArg)
            ])
        let sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: true)]
        let results: [CTask] = queryWithPredicate(compoundPredicate, sortDescriptors: sortDescriptors)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func queryUnsyncedTasks() -> [Task] {
        
        let predicate = NSPredicate(format: "lastModifiedDate == nil")
        let results: [CTask] = queryWithPredicate(predicate, sortDescriptors: nil)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func queryChangedTasks (sinceDate: Date, completion: @escaping ([Task], NSError?) -> Void) {
        
        let predicate = NSPredicate(format: "lastModifiedDate > %@", sinceDate as CVarArg)
        let results: [CTask] = queryWithPredicate(predicate, sortDescriptors: nil)
        let tasks = tasksFromCTasks(results)
        
        completion(tasks, nil)
    }
    
    func deleteTask (_ task: Task, completion: @escaping ((_ success: Bool) -> Void)) {
        
        guard let context = managedObjectContext else {
            return
        }
        
        let ctask = ctaskFromTask(task)
        context.delete(ctask)
        saveContext()
        completion(true)
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task) -> Void)) {
        
        let ctask = ctaskFromTask(task)
        saveContext()
        
        completion( taskFromCTask(ctask))
    }
}

extension CoreDataRepository {
    
    fileprivate func taskFromCTask (_ ctask: CTask) -> Task {
        
        return Task(lastModifiedDate: ctask.lastModifiedDate,
                    startDate: ctask.startDate,
                    endDate: ctask.endDate!,
                    notes: ctask.notes,
                    taskNumber: ctask.taskNumber,
                    taskType: TaskType(rawValue: ctask.taskType!.intValue)!,
                    objectId: ctask.objectId!
        )
    }
    
    fileprivate func tasksFromCTasks (_ ctasks: [CTask]) -> [Task] {
        
        var tasks = [Task]()
        for ctask in ctasks {
            tasks.append(self.taskFromCTask(ctask))
        }
        
        return tasks
    }
    
    fileprivate func ctaskFromTask (_ task: Task) -> CTask {
        
        let taskPredicate = NSPredicate(format: "objectId == %@", task.objectId)
        let tasks: [CTask] = queryWithPredicate(taskPredicate, sortDescriptors: nil)
        var ctask: CTask? = tasks.first
        if ctask == nil {
            ctask = NSEntityDescription.insertNewObject(forEntityName: String(describing: CTask.self),
                                                        into: managedObjectContext!) as? CTask
        }
        if ctask?.objectId == nil {
            ctask?.objectId = task.objectId
        }
        
        return updatedCTask(ctask!, withTask: task)
    }
    
    // Update only updatable properties. objectId can't be updated
    fileprivate func updatedCTask (_ ctask: CTask, withTask task: Task) -> CTask {
        
        ctask.taskNumber = task.taskNumber
        ctask.taskType = NSNumber(value: task.taskType.rawValue)
        ctask.notes = task.notes
        ctask.startDate = task.startDate
        ctask.endDate = task.endDate
        ctask.lastModifiedDate = task.lastModifiedDate
        
        return ctask
    }
}
