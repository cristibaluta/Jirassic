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
    var startDate: Date?
    var endDate: Date?
    var notes: String?
    var taskNumber: String?
    var taskType: Int = 0
    var objectId: String?
    
    override func primaryKey() -> String {
        return "objectId"
    }
    
    override var description: String {
        return "<STask: lastModifiedDate: \(String(describing: lastModifiedDate)) \n startDate: \(String(describing: startDate)) \n endDate: \(String(describing: endDate)) \n notes: \(String(describing: notes)) \n taskNumber: \(String(describing: taskNumber)) \n taskType: \(String(describing: taskType)) \n objectId: \(String(describing: objectId))>"
    }
}
