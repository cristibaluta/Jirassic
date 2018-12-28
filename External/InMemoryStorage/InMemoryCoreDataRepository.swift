//
//  InMemoryRepository.swift
//  Jirassic
//
//  Created by Baluta Cristian on 29/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import CoreData
//@testable import Jirassic_no_cloud

// TODO  try  to configure this so the model does not need to be in the Jirassic Appstore target but in the tests target
class InMemoryCoreDataRepository: CoreDataRepository {
	
    override func container() -> NSPersistentContainer {
        let storeDescriptor = NSPersistentStoreDescription()
        storeDescriptor.shouldAddStoreAsynchronously = false
        storeDescriptor.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: self.databaseName, managedObjectModel: self.managedObjectModel)
        container.persistentStoreDescriptions = [storeDescriptor]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let testBundle = Bundle(for: type(of: self))
//        return NSManagedObjectModel.mergedModel(from: nil)!
        let managedObjectModel = NSManagedObjectModel.mergedModel(from: [testBundle])
        return managedObjectModel!
    }()
}
