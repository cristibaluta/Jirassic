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
    
    fileprivate let databaseName = "Jirassic"
    
    lazy var applicationDocumentsDirectory: URL = {
        
        #if os(iOS)
            
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return urls.last as URL!
            
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
    
    func persistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        let coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = applicationDocumentsDirectory.appendingPathComponent("\(databaseName).coredata")
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            return coordinator
        } catch _ {
            return nil
        }
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: self.databaseName, withExtension: "momd")
        return NSManagedObjectModel(contentsOf: modelURL!)!
    }()
    
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
