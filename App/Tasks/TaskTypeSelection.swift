//
//  TaskTypeSelection.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/08/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskTypeSelection {
    
    fileprivate let kLastSelectedTabKey = "LastSelectedTabKey"
    
    func setType (_ type: ListType) {
        UserDefaults.standard.set(type.rawValue, forKey: kLastSelectedTabKey)
        UserDefaults.standard.synchronize()
    }
    
    func lastType() -> ListType {
        
        if let type = ListType(rawValue: UserDefaults.standard.integer(forKey: kLastSelectedTabKey)) {
            return type
        }
        return ListType.tasks
    }
}
