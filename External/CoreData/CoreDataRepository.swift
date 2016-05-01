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
    
    init() {
        
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls.last as NSURL!
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("Jirassic", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Jirassic.sqlite")
        
        do {
            let persistentStore = try coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
            return coordinator
        } catch _ {
            return nil
        }
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        guard let coordinator = self.persistentStoreCoordinator else {
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
    
    private func queryTasksWithPredicate (predicate: NSPredicate) -> [CTask] {
        
        guard let context = managedObjectContext else {
            return []
        }
        
        let request = NSFetchRequest(entityName: String(CTask))
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        
        do {
            let results = try context.executeFetchRequest(request)
            return results as! [CTask]
        } catch _ {
            return []
        }
    }
}

extension CoreDataRepository {
    
    private func taskFromCTask (ctask: CTask) -> Task {
        
        var task = Task()
        task.taskId = ctask.taskId
        task.taskType = ctask.taskType
        task.notes = ctask.notes
        task.startDate = ctask.startDate
        task.endDate = ctask.endDate
        
        return task
    }
    
    private func tasksFromCTasks (ctasks: [CTask]) -> [Task] {
        
        var tasks = [Task]()
        for ctask in ctasks {
            tasks.append(self.taskFromCTask(ctask))
        }
        
        return tasks
    }
    
    private func ctaskFromTask (task: Task) -> CTask {
        
        let taskPredicate = NSPredicate(format: "taskId == %@", task.taskId!)
        let tasks = queryTasksWithPredicate(taskPredicate)
        if tasks.count > 0 {
            return updatedCTask(tasks.first!, withTask: task)
        }
        
        let ctask = NSEntityDescription.insertNewObjectForEntityForName(String(CTask),
                    inManagedObjectContext: managedObjectContext!) as! CTask
        
        return updatedCTask(ctask, withTask: task)
    }
    
    private func updatedCTask (ctask: CTask, withTask task: Task) -> CTask {
        
        ctask.taskId = task.taskId
        ctask.issueId = task.issueId
        ctask.notes = task.notes
        ctask.startDate = task.startDate
        ctask.endDate = task.endDate
        
        return ctask
    }
    
}

extension CoreDataRepository: Repository {
    
    func currentUser() -> User {
        return remoteRepository.currentUser()
    }
    
    func loginWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        remoteRepository.loginWithCredentials(credentials, completion: completion)
    }
    
    func registerWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        remoteRepository.registerWithCredentials(credentials, completion: completion)
    }
    
    func logout() {
        remoteRepository.logout()
    }
    
    func queryTasks (page: Int, completion: ([Task], NSError?) -> Void) {
        
        let userPredicate = NSPredicate(format: "userId = %@", "")
        let results = queryTasksWithPredicate(userPredicate)
        let tasks = tasksFromCTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (day: NSDate) -> [Task] {
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate(format: "startDate >= %@ AND startDate <= %@", day.startOfDay(), day.endOfDay()),
            NSPredicate(format: "endDate >= %@ AND endDate <= %@", day.startOfDay(), day.endOfDay())
        ])
        let results = queryTasksWithPredicate(compoundPredicate)
        let tasks = tasksFromCTasks(results)
        
        return tasks
    }
    
    func queryUnsyncedTasks() -> [Task] {
        return []
    }
    
    func deleteTask (dataToDelete: Task) {
        remoteRepository.deleteTask(dataToDelete)
    }
    
    func saveTask (theTask: Task, completion: ((success: Bool) -> Void)) {
        
        let taskPredicate = NSPredicate(format: "taskId = %@", theTask.taskId!)
        let results = queryTasksWithPredicate(taskPredicate)
        if results.count > 0 {
            
        }
        
        let _ = ctaskFromTask(theTask)
        saveContext()
    }
}
