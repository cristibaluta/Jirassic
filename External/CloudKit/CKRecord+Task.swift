//
//  CKRecord+Task.swift
//  Jirassic
//
//  Created by Cristian Baluta on 21/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {

    func toTask() -> Task {

        return Task(lastModifiedDate: self.modificationDate,
                    startDate: self["startDate"] as? Date,
                    endDate: self["endDate"] as! Date,
                    notes: self["notes"] as? String,
                    taskNumber: self["taskNumber"] as? String,
                    taskTitle: self["taskTitle"] as? String,
                    taskType: TaskType(rawValue: (self["taskType"] as! NSNumber).intValue)!,
                    objectId: self["objectId"] as? String,
                    projectId: self["projectId"] as? String
        )
    }

    func update (with task: Task) {

        self["startDate"] = task.startDate as CKRecordValue?
        self["endDate"] = task.endDate as CKRecordValue
        self["notes"] = task.notes as CKRecordValue?
        self["taskNumber"] = task.taskNumber as CKRecordValue?
        self["taskTitle"] = task.taskTitle as CKRecordValue?
        self["taskType"] = task.taskType.rawValue as CKRecordValue
        self["objectId"] = task.objectId as CKRecordValue?
        self["projectId"] = task.projectId as CKRecordValue?
    }
}
