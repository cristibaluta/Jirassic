//
//  SSettings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class SSettings: SQLTable {
    
    var autotrack: Bool = false
    var autotrackingMode: Int = 0
    var trackLunch: Bool = false
    var trackScrum: Bool = false
    var trackMeetings: Bool = false
    var trackCodeReviews: Bool = false
    var trackWastedTime: Bool = false
    var trackStartOfDay: Bool = false
    var enableBackup: Bool = false
    
    var startOfDayTime: Date? = nil
    var endOfDayTime: Date? = nil
    var lunchTime: Date? = nil
    var scrumTime: Date? = nil
    var minSleepDuration: Date? = nil
    var minCodeRevDuration: Date? = nil
    var codeRevLink: String? = nil
    var minWasteDuration: Date? = nil
    var wasteLinks: String? = nil
    
    var i: Int = 0
    
    override func primaryKey() -> String {
        return "i"
    }
    
}
