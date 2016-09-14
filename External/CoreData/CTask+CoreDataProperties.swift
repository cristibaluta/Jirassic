//
//  CTask+CoreDataProperties.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CTask {

    @NSManaged var lastModifiedDate: Date?
    @NSManaged var creationDate: Date?
    @NSManaged var endDate: Date?
    @NSManaged var notes: String?
    @NSManaged var taskNumber: String?
    @NSManaged var taskType: NSNumber?
    @NSManaged var taskId: String?

}
