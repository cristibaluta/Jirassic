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
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Spoto.sqlite")
        
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

extension CoreDataRepository: Repository {

    func currentUser() -> User {
        return remoteRepository.currentUser()
    }
    
    func queryTasks (completion: ([Task], NSError?) -> Void) {
        
        guard let puser = PUser.currentUser() else {
            return
        }
//        query.fromLocalDatastore()
//        query.whereKey(kUserKey, equalTo: puser)
//        query.findObjectsInBackgroundWithBlock( { [weak self] (objects: [PFObject]?, error: NSError?) in
//            if let strongSelf = self {
//                RCLogO("Found \(objects?.count) objects in LocalDatastore")
//                strongSelf.processPTasks(objects, error: error, completion: completion)
//            }
//        })
        remoteRepository.queryTasks(completion)
    }
    
    func allCachedTasks() -> [Task] {
        return remoteRepository.allCachedTasks()
    }
    
    func deleteTask (dataToDelete: Task) {
        remoteRepository.deleteTask(dataToDelete)
    }
    
    func updateTask (theTask: Task, completion: ((success: Bool) -> Void)) {
        remoteRepository.updateTask(theTask, completion: completion)
    }
}
