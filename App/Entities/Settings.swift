//
//  Settings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

enum TrackingMode: Int {
    case auto
    case notif
}

struct Settings {
    
    var autotrack: Bool
    var autotrackingMode: TrackingMode
    var trackLunch: Bool
    var trackScrum: Bool
    var trackMeetings: Bool
    var trackCodeReviews: Bool
    var trackWastedTime: Bool
    var trackStartOfDay: Bool
    var enableBackup: Bool
    
    var startOfDayTime: Date
    var endOfDayTime: Date
    var lunchTime: Date
    var scrumTime: Date
    var minSleepDuration: Date
    var minCodeRevDuration: Date
    var codeRevLink: String
    var minWasteDuration: Date
    var wasteLinks: [String]
}
