//
//  SMetadata.swift
//  Jirassic
//
//  Created by Cristian Baluta on 13/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation

class SMetadata: SQLTable {
    
    var i: Int = 0
    var tasksLastSyncDate: Date? = nil
    var projectsLastSyncDate: Date? = nil
    var tasksLastSyncToken: String? = nil
    var projectsLastSyncToken: String? = nil
    
    override func primaryKey() -> String {
        return "i"
    }
}
