//
//  CoreDataManager.swift
//  Jirassic
//
//  Created by Cristian Baluta on 15/04/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CoreData

class CoreDataRepository {
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last as NSURL!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Jirassic", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    func persistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Jirassic.sqlite")
        
        do {
            try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            return coordinator
        } catch _ {
            return nil
        }
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        guard let coordinator = self.persistentStoreCoordinator() else {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            if moc.hasChanges {
                do {
                    try moc.save()
                } catch _ {
                    
                }
            }
        }
    }
}

extension CoreDataRepository {
    
    private func queryWithPredicate<T:NSManagedObject> (predicate: NSPredicate) -> [T] {
        
        guard let context = managedObjectContext else {
            return []
        }
        
        let request = NSFetchRequest(entityName: String(T))
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        
        do {
            let results = try context.executeFetchRequest(request)
            return results as! [T]
        } catch _ {
            return []
        }
    }
}

extension CoreDataRepository {
    
    private func taskFromCTask (ctask: CTask) -> Task {
        
        return Task(startDate: ctask.startDate,
                    endDate: ctask.endDate,
                    notes: ctask.notes,
                    issueType: ctask.issueType,
                    issueId: ctask.issueId,
                    taskType: ctask.taskType,
                    taskId: ctask.taskId
        )
    }
    
    private func tasksFromCTasks (ctasks: [CTask]) -> [Task] {
        
        var tasks = [Task]()
        for ctask in ctasks {
            tasks.append(self.taskFromCTask(ctask))
        }
        
        return tasks
    }
    
    private func ctaskFromTask (task: Task) -> CTask {
        
        var ctask: CTask?
        if let taskId = task.taskId {
            let taskPredicate = NSPredicate(format: "taskId == %@", taskId)
            let tasks: [CTask] = queryWithPredicate(taskPredicate)
            ctask = tasks.first
        }
        if ctask == nil {
            ctask = NSEntityDescription.insertNewObjectForEntityForName(String(CTask),
                    inManagedObjectContext: managedObjectContext!) as? CTask
        }
        if task.taskId == nil {
            ctask?.taskId = String.random()
        }
        
        return updatedCTask(ctask!, withTask: task)
    }
    
    // Update only updatable properties. taskId can't be updated
    private func updatedCTask (ctask: CTask, withTask task: Task) -> CTask {
        
        ctask.issueId = task.issueId
        ctask.issueType = task.issueType
        ctask.notes = task.notes
        ctask.startDate = task.startDate
        ctask.endDate = task.endDate
        
        return ctask
    }
    
}

extension CoreDataRepository: Repository {
    
    func currentUser() -> User {
        
        let userPredicate = NSPredicate(format: "isLoggedIn == YES")
        let cusers: [CUser] = queryWithPredicate(userPredicate)
        if let cuser = cusers.last {
            return User(isLoggedIn: true, email: cuser.email, userId: cuser.userId, lastSyncDate: cuser.lastSyncDate)
        }
        
        return User(isLoggedIn: false, email: nil, userId: nil, lastSyncDate: nil)
    }
    
    func loginWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func registerWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func logout() {
        
        guard let context = managedObjectContext else {
            return
        }
        
        if #available(OSX 1000.11, *) {
            // TODO: This seems not to work under 10.11
            let fetchRequest = NSFetchRequest(entityName: String(CTask))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try persistentStoreCoordinator()?.executeRequest(deleteRequest, withContext: context)
            } catch let error as NSError {
                RCLog(error)
            }
        } else {
            let fetchRequest = NSFetchRequest()
            fetchRequest.entity = NSEntityDescription.entityForName(String(CTask), inManagedObjectContext: context)
            fetchRequest.includesPropertyValues = false
            do {
                if let results = try context.executeFetchRequest(fetchRequest) as? [NSManagedObject] {
                    for result in results {
                        context.deleteObject(result)
                    }
                    try context.save()
                }
            } catch {
                
            }
        }
    }
    
    func queryTasks (page: Int, completion: ([Task], NSError?) -> Void) {
        
        let userPredicate = NSPredicate(format: "userId == nil")
        let results: [CTask] = queryWithPredicate(userPredicate)
        let tasks = tasksFromCTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (day: NSDate) -> [Task] {
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "startDate >= %@ AND startDate <= %@", day.startOfDay(), day.endOfDay()),
            NSPredicate(format: "endDate >= %@ AND endDate <= %@", day.startOfDay(), day.endOfDay())
        ])
        let results: [CTask] = queryWithPredicate(compoundPredicate)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func queryUnsyncedTasks() -> [Task] {
        
        let userPredicate = NSPredicate(format: "lastModifiedDate == nil")
        let results: [CTask] = queryWithPredicate(userPredicate)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func deleteTask (task: Task, completion: ((success: Bool) -> Void)) {
        
        guard let context = managedObjectContext else {
            return
        }
        guard let _ = task.taskId else {
            fatalError("Can't delete a task without a taskId")
        }
        
        let ctask = ctaskFromTask(task)
        context.deleteObject(ctask)
        saveContext()
        completion(success: true)
    }
    
    func saveTask (task: Task, completion: (success: Bool) -> Void) -> Task {
        
        let ctask = ctaskFromTask(task)
        saveContext()
        
        return taskFromCTask(ctask)
    }
}
