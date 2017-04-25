//
//  CTask.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class STask: SQLTable {
    
    var lastModifiedDate: Date?
    var markedForDeletion = false
    var startDate: Date?
    var endDate: Date?
    var notes: String?
    var taskNumber: String?
    var taskTitle: String?
    var taskType: Int = 0
    var objectId: String?
    
    override func primaryKey() -> String {
        return "objectId"
    }
    
    override var description: String {
        return "<STask: lastModifiedDate: \(String(describing: lastModifiedDate ?? nil)) \n markedForDeletion: \(markedForDeletion) \n startDate: \(String(describing: startDate)) \n endDate: \(String(describing: endDate)) \n notes: \(String(describing: notes)) \n taskNumber: \(String(describing: taskNumber)) \n taskTitle: \(String(describing: taskTitle)) \n taskType: \(String(describing: taskType)) \n objectId: \(String(describing: objectId))>"
    }
}
