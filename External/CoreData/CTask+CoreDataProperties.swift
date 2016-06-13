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

    @NSManaged var lastModifiedDate: NSDate?
    @NSManaged var creationDate: NSDate?
    @NSManaged var endDate: NSDate?
    @NSManaged var notes: String?
    @NSManaged var issueType: String?
    @NSManaged var taskType: NSNumber?
    @NSManaged var issueId: String?
    @NSManaged var taskId: String?

}
