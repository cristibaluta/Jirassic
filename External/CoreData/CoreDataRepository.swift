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
    
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let baseUrl = urls.last!
        let url = baseUrl.appendingPathComponent("Jirassic")
        RCLog(url)
        
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
                return baseUrl
            }
        }
        return url
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Jirassic", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    func persistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Jirassic.sqlite")
        
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            return coordinator
        } catch _ {
            return nil
        }
    }
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        
        guard let coordinator = self.persistentStoreCoordinator() else {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
    
    fileprivate func queryWithPredicate<T:NSManagedObject> (_ predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        
        guard let context = managedObjectContext else {
            return []
        }
        
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        //let request = T.fetchRequest()
        request.returnsObjectsAsFaults = false
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        do {
            let results = try context.fetch(request)
            return results
        } catch _ {
            return []
        }
    }
}

extension CoreDataRepository {
    
    fileprivate func taskFromCTask (_ ctask: CTask) -> Task {
        
        return Task(startDate: nil,
                    endDate: ctask.endDate!,
                    notes: ctask.notes,
                    taskNumber: ctask.taskNumber,
                    taskType: ctask.taskType!,
                    taskId: ctask.taskId!
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
        
        let taskPredicate = NSPredicate(format: "taskId == %@", task.taskId)
        let tasks: [CTask] = queryWithPredicate(taskPredicate, sortDescriptors: nil)
        var ctask: CTask? = tasks.first
        if ctask == nil {
            ctask = NSEntityDescription.insertNewObject(forEntityName: String(describing: CTask.self),
                    into: managedObjectContext!) as? CTask
        }
        if ctask?.taskId == nil {
            ctask?.taskId = task.taskId
        }
        
        return updatedCTask(ctask!, withTask: task)
    }
    
    // Update only updatable properties. taskId can't be updated
    fileprivate func updatedCTask (_ ctask: CTask, withTask task: Task) -> CTask {
        
        ctask.taskNumber = task.taskNumber
        ctask.taskType = task.taskType
        ctask.notes = task.notes
        ctask.endDate = task.endDate
        
        return ctask
    }
}

extension CoreDataRepository {
    
    fileprivate func settingsFromCSettings (_ csettings: CSettings) -> Settings {
        
        return Settings(autoTrackStartOfDay: csettings.autoTrackStartOfDay!.boolValue,
                        autoTrackLunch: csettings.autoTrackLunch!.boolValue,
                        autoTrackScrum: csettings.autoTrackScrum!.boolValue,
                        autoTrackMeetings: csettings.autoTrackMeetings!.boolValue,
                        startOfDayTime: csettings.startOfDayTime!,
                        lunchTime: csettings.lunchTime!,
                        scrumMeetingTime: csettings.scrumMeetingTime!,
                        minMeetingDuration: csettings.minMeetingDuration!
        )
    }
    
    fileprivate func csettingsFromSettings (_ settings: Settings) -> CSettings {
        
        let results: [CSettings] = queryWithPredicate(nil, sortDescriptors: nil)
        var csettings: CSettings? = results.first
        if csettings == nil {
            csettings = NSEntityDescription.insertNewObject(forEntityName: String(describing: CSettings.self),
                                                            into: managedObjectContext!) as? CSettings
        }
        csettings?.autoTrackStartOfDay = NSNumber(value: settings.autoTrackStartOfDay)
        csettings?.autoTrackLunch = NSNumber(value: settings.autoTrackLunch)
        csettings?.autoTrackScrum = NSNumber(value: settings.autoTrackScrum)
        csettings?.autoTrackMeetings = NSNumber(value: settings.autoTrackMeetings)
        csettings?.startOfDayTime = settings.startOfDayTime
        csettings?.lunchTime = settings.lunchTime
        csettings?.scrumMeetingTime = settings.scrumMeetingTime
        csettings?.minMeetingDuration = settings.minMeetingDuration
        
        return csettings!
    }
}

extension CoreDataRepository: RepositoryUser {
    
    func currentUser() -> User {
        
        let userPredicate = NSPredicate(format: "isLoggedIn == YES")
        let cusers: [CUser] = queryWithPredicate(userPredicate, sortDescriptors: nil)
        if let cuser = cusers.last {
            return User(isLoggedIn: true, email: cuser.email, userId: cuser.userId, lastSyncDate: cuser.lastSyncDate)
        }
        
        return User(isLoggedIn: false, email: nil, userId: nil, lastSyncDate: nil)
    }
    
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func logout() {
        
        guard let context = managedObjectContext else {
            return
        }
        
        if #available(OSX 1000.11, *) {
            // TODO: This seems not to work under 10.11
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CTask.self))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try persistentStoreCoordinator()?.execute(deleteRequest, with: context)
            } catch let error as NSError {
                RCLog(error)
            }
        } else {
            let fetchRequest = NSFetchRequest<CTask>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: String(describing: CTask.self), in: context)
            fetchRequest.includesPropertyValues = false
            do {
                let results = try context.fetch(fetchRequest)
                for result in results {
                    context.delete(result)
                }
                try context.save()
            } catch {
                
            }
        }
    }
}

extension CoreDataRepository: RepositoryTasks {

    func queryTasks (_ page: Int, completion: ([Task], NSError?) -> Void) {
        
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
    
    func deleteTask (_ task: Task, completion: ((_ success: Bool) -> Void)) {
        
        guard let context = managedObjectContext else {
            return
        }
        
        let ctask = ctaskFromTask(task)
        context.delete(ctask)
        saveContext()
        completion(true)
    }
    
    func saveTask (_ task: Task, completion: (_ success: Bool) -> Void) -> Task {
        
        let ctask = ctaskFromTask(task)
        saveContext()
        
        return taskFromCTask(ctask)
    }
    
}

extension CoreDataRepository: RepositorySettings {
    
    func settings() -> Settings {
        
        let results: [CSettings] = queryWithPredicate(nil, sortDescriptors: nil)
        var csettings: CSettings? = results.first
        if csettings == nil {
            csettings = NSEntityDescription.insertNewObject(forEntityName: String(describing: CSettings.self),
                                                            into: managedObjectContext!) as? CSettings
            csettings?.autoTrackLunch = 1
            csettings?.autoTrackScrum = 1
            csettings?.autoTrackStartOfDay = 1
            csettings?.autoTrackMeetings = 1
            csettings?.lunchTime = Date(hour: 13, minute: 0)
            csettings?.scrumMeetingTime = Date(hour: 10, minute: 30)
            csettings?.startOfDayTime = Date(hour: 9, minute: 0)
            csettings?.minMeetingDuration = Date(hour: 0, minute: 20)
            saveContext()
        }
        return settingsFromCSettings(csettings!)
    }
    
    func saveSettings (_ settings: Settings) {
        
        let _ = csettingsFromSettings(settings)
        saveContext()
    }
}
