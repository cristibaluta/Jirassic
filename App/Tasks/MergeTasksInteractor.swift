//
//  MergeTasksInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class MergeTasksInteractor {
    
    /// Merge the two list of tasks, avoid duplicates, and sort ascending
    func merge (tasks: [Task], with gitTasks: [Task]) -> [Task] {
        
        var arr = [Task]()
        arr += tasks
        arr.mergeElements(newElements: gitTasks)

        // Remove duplicates
        var buffer = [Task]()
        var added = [Task]()
        for elem in arr {
            var duplicateHasTaskNumber = false
            if !added.contains(where: {
                let isDuplicate = abs(elem.endDate.timeIntervalSince($0.endDate)) < 5.0
                if isDuplicate {
                    duplicateHasTaskNumber = $0.taskNumber?.count ?? 0 > 0
                }
                return isDuplicate
            }) {
                buffer.append(elem)
                added.append(elem)
            }
        }

        buffer.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })

        return buffer
    }
}

fileprivate extension Array where Element == Task {

    fileprivate mutating func mergeElements<C : Collection>(newElements: C) where C.Iterator.Element == Element {
        
        let filteredList = newElements.filter( {
            let gitTask = $0
            return !self.contains(where: { gitTask.endDate.compare($0.endDate) == .orderedSame })
        })
        self += filteredList
    }
}
