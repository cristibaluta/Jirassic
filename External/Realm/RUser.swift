//
//  CUser.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import RealmSwift

class RUser: Object {
    
    dynamic var userId: String?
    dynamic var email: String?
    dynamic var lastSyncDate: Date?
    dynamic var isLoggedIn: Bool = false

}
