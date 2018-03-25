//
//  TimeInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class TimeInteractor {
    
    let settings: Settings!
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    func workingDayLength() -> TimeInterval {
        return settings.settingsTracking.endOfDayTime.dateByKeepingTime().timeIntervalSince(
            settings.settingsTracking.startOfDayTime.dateByKeepingTime())
    }
    
    func workedDayLength() -> TimeInterval {
        return Date().timeIntervalSince( settings.settingsTracking.startOfDayTime.dateByKeepingTime() )
    }
}
