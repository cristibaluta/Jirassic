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
        arr.sort(by: { $0.endDate.compare($1.endDate) == .orderedAscending })
        
        return arr
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
