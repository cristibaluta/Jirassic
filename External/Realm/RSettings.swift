//
//  CSettings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import RealmSwift

class RSettings: Object {
    
    dynamic var startOfDayEnabled: Bool = false
    dynamic var lunchEnabled: Bool = false
    dynamic var scrumEnabled: Bool = false
    dynamic var meetingEnabled: Bool = false
    dynamic var autoTrackEnabled: Bool = false
    dynamic var trackingMode: Int = 0
    
    dynamic var startOfDayTime: Date?
    dynamic var endOfDayTime: Date?
    dynamic var lunchTime: Date?
    dynamic var scrumTime: Date?
    dynamic var minSleepDuration: Date?
    
}
