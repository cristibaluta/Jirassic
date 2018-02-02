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
    
    var enableBackup: Bool
    var settingsTracking: SettingsTracking
    var settingsBrowser: SettingsBrowser
}

struct SettingsTracking {
    
    var autotrack: Bool
    var autotrackingMode: TrackingMode
    var trackLunch: Bool
    var trackScrum: Bool
    var trackMeetings: Bool
    var trackStartOfDay: Bool
    
    var startOfDayTime: Date
    var endOfDayTime: Date
    var lunchTime: Date
    var scrumTime: Date
    var minSleepDuration: Int
}

struct SettingsBrowser {

    var trackCodeReviews: Bool
    var trackWastedTime: Bool

    var minCodeRevDuration: Int
    var codeRevLink: String
    var minWasteDuration: Int
    var wasteLinks: [String]
}
