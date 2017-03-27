//
//  CTask.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import RealmSwift

class RTask: Object {
    
    dynamic var lastModifiedDate: Date?
    dynamic var creationDate: Date?
    dynamic var startDate: Date?
    dynamic var endDate: Date?
    dynamic var notes: String?
    dynamic var taskNumber: String?
    dynamic var taskType: Int = 0
    dynamic var objectId: String?
    
}
