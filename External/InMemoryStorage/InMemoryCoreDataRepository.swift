//
//  InMemoryRepository.swift
//  Jirassic
//
//  Created by Baluta Cristian on 29/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import CoreData

class InMemoryCoreDataRepository: CoreDataRepository {
	
    override func persistentStoreCoordinator() -> NSPersistentStoreCoordinator? {
        
        if let mom = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()]) {
            
            let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
            do {
                try coordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
                return coordinator
            } catch _ {
                
            }
        }
        
        return nil
    }
}
