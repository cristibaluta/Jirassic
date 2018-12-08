//
//  CoreDataRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 15/04/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CoreData

class CoreDataRepository {
    
    internal let databaseName = "Jirassic"
    
    internal lazy var applicationDocumentsDirectory: URL = {
        
        #if os(iOS)
            
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls.last!
            
        #else
            
            let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            let baseUrl = urls.last!
            let url = baseUrl.appendingPathComponent(self.databaseName)
            RCLog(url)
            
            if !FileManager.default.fileExists(atPath: url.path) {
                do {
                    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                    return baseUrl
                }
            }
            return url
            
        #endif
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        return self.persistentContainer.viewContext
    }()
    
    lazy var persistentContainer: NSPersistentContainer = {
        return container()
    }()
    
    internal func container() -> NSPersistentContainer {
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(self.databaseName).coredata")
        let storeDescriptor = NSPersistentStoreDescription(url: url)
        storeDescriptor.shouldMigrateStoreAutomatically = true
        storeDescriptor.shouldInferMappingModelAutomatically = true
        storeDescriptor.type = NSSQLiteStoreType
        
        let container = NSPersistentContainer(name: self.databaseName)
        container.persistentStoreDescriptions = [storeDescriptor]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
    
    func saveContext () {
        if let moc = self.managedObjectContext, moc.hasChanges {
            try? moc.save()
        }
    }
    
    convenience init (documentsDirectory: String) {
        self.init()
        applicationDocumentsDirectory = URL(fileURLWithPath: documentsDirectory)
    }
}

extension CoreDataRepository {
    
    internal func queryWithPredicate<T:NSManagedObject> (_ predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T] {
        
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
