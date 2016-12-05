//
//  Settings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

enum TaskTrackingMode: Int {
    case auto
    case notif
}

struct Settings {
    
    var startOfDayEnabled: Bool
    var lunchEnabled: Bool
    var scrumEnabled: Bool
    var meetingEnabled: Bool
    var autoTrackEnabled: Bool
    var trackingMode: TaskTrackingMode
    
    var startOfDayTime: Date
    var endOfDayTime: Date
    var lunchTime: Date
    var scrumTime: Date
    var minSleepDuration: Date
}
