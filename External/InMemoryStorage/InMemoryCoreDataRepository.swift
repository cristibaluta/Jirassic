//
//  InMemoryRepository.swift
//  Jirassic
//
//  Created by Baluta Cristian on 29/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import CoreData

class InMemoryCoreDataRepository: CoreDataRepository {
	
    override func storeDescriptorType() -> String {
        return NSInMemoryStoreType
    }
    
}
