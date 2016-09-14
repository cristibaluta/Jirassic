//
//  CUser+CoreDataProperties.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CUser {

    @NSManaged var userId: String?
    @NSManaged var email: String?
    @NSManaged var lastSyncDate: Date?
    @NSManaged var isLoggedIn: NSNumber?

}
