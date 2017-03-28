//
//  CSettings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class SSettings: SQLTable {
    
    var startOfDayEnabled: Bool = false
    var lunchEnabled: Bool = false
    var scrumEnabled: Bool = false
    var meetingEnabled: Bool = false
    var autoTrackEnabled: Bool = false
    var trackingMode: Int = 0
    
    var startOfDayTime: Date? = nil
    var endOfDayTime: Date? = nil
    var lunchTime: Date? = nil
    var scrumTime: Date? = nil
    var minSleepDuration: Date? = nil
    
}
