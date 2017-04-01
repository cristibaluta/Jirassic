//
//  SUser.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class SUser: SQLTable {
    
    var userId: String?
    var email: String?
    var lastSyncDate: Date?
    var isLoggedIn: Bool = false
    
    override func primaryKey() -> String {
        return "userId"
    }
    
}
