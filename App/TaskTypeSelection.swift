//
//  TaskTypeSelection.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/08/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskTypeSelection {
    
    private let kLastSelectedTabKey = "LastSelectedTabKey"
    
    func setType (type: ListType) {
        NSUserDefaults.standardUserDefaults().setObject(type.rawValue, forKey: kLastSelectedTabKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func lastType() -> ListType {
        
        if let type = ListType(rawValue: NSUserDefaults.standardUserDefaults().integerForKey(kLastSelectedTabKey)) {
            return type
        }
        return ListType.AllTasks
    }
}
