//
//  CTask.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CoreData


class CTask: NSManagedObject {
    
    @NSManaged var lastModifiedDate: Date?
    @NSManaged var creationDate: Date?
    @NSManaged var startDate: Date?
    @NSManaged var endDate: Date?
    @NSManaged var notes: String?
    @NSManaged var taskNumber: String?
    @NSManaged var taskType: NSNumber?
    @NSManaged var objectId: String?
    @NSManaged var remoteId: String?
    
}
