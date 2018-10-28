//
//  MergeTasksInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class MergeTasksInteractor {
    
    private let secondsAllowed = 5.0
    
    /// Merge the two list of tasks, remove duplicates, and sort ascending
    func merge (tasks: [Task], with gitTasks: [Task]) -> [Task] {
        
        let all = tasks + gitTasks
        
        // Remove duplicates
        var unique = [Task]()
        for task in all {
            var originalHasTaskNumber = false
            var duplicateHasTaskNumber = false
            let isUnique = !unique.contains(where: {
                originalHasTaskNumber = task.taskNumber?.count ?? 0 > 0
                let isDuplicate = task.taskType == $0.taskType && abs(task.endDate.timeIntervalSince($0.endDate)) < secondsAllowed
                if isDuplicate {
                    duplicateHasTaskNumber = $0.taskNumber?.count ?? 0 > 0
                }
                return isDuplicate
            })
            if isUnique {
                unique.append(task)
            } else if originalHasTaskNumber && !duplicateHasTaskNumber {
                unique.removeAll(where: { abs(task.endDate.timeIntervalSince($0.endDate)) < secondsAllowed })
                unique.append(task)
            }
        }
        
        // Sort by date
        unique.sort(by: {
            // If tasks have the same date might be the end of the day compared with the last task
            // In this case endDay should be the latter task
            guard $0.endDate != $1.endDate else {
                return $1.taskType == .endDay
            }
            return $0.endDate < $1.endDate
        })

        return unique
    }
}

//fileprivate extension Array where Element == Task {
//
//    fileprivate mutating func mergeElements<C : Collection>(newElements: C) where C.Iterator.Element == Element {
//
//        let filteredList = newElements.filter( {
//            let gitTask = $0
//            return !self.contains(where: { gitTask.endDate.compare($0.endDate) == .orderedSame })
//        })
//        self += filteredList
//    }
//}
