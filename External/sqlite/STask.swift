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
    var creationDate: Date?
    var startDate: Date?
    var endDate: Date?
    var notes: String?
    var taskNumber: String?
    var taskType: Int = 0
    var objectId: String?
    
}
