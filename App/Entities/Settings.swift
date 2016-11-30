//
//  Settings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

struct Settings {
    
    var autoTrackStartOfDay: Bool
    var autoTrackLunch: Bool
    var autoTrackScrum: Bool
    var autoTrackMeetings: Bool
    var showWakeUpSuggestions: Bool
    
    var startOfDayTime: Date
    var lunchTime: Date
    var scrumMeetingTime: Date
    var minMeetingDuration: Date
}
