//
//  SqliteRepository+Settings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension SqliteRepository: RepositorySettings {
    
    func settings() -> Settings {
        
        let results: [SSettings] = queryWithPredicate(nil, sortingKeyPath: nil)
        var rsettings: SSettings? = results.first
        if rsettings == nil {
            rsettings = SSettings()
            rsettings?.startOfDayEnabled = true
            rsettings?.lunchEnabled = true
            rsettings?.scrumEnabled = true
            rsettings?.meetingEnabled = true
            rsettings?.autoTrackEnabled = true
            rsettings?.trackingMode = 1
            rsettings?.startOfDayTime = Date(hour: 9, minute: 0)
            rsettings?.endOfDayTime = Date(hour: 17, minute: 0)
            rsettings?.lunchTime = Date(hour: 13, minute: 0)
            rsettings?.scrumTime = Date(hour: 10, minute: 30)
            rsettings?.minSleepDuration = Date(hour: 0, minute: 13)
        }
        return settingsFromRSettings(rsettings!)
    }
    
    func saveSettings (_ settings: Settings) {
        
        let _ = rsettingsFromSettings(settings)
        
    }
    
    fileprivate func settingsFromRSettings (_ rsettings: SSettings) -> Settings {
        
        return Settings(startOfDayEnabled: rsettings.startOfDayEnabled,
                        lunchEnabled: rsettings.lunchEnabled,
                        scrumEnabled: rsettings.scrumEnabled,
                        meetingEnabled: rsettings.meetingEnabled,
                        autoTrackEnabled: rsettings.autoTrackEnabled,
                        trackingMode: TaskTrackingMode(rawValue: rsettings.trackingMode)!,
                        startOfDayTime: rsettings.startOfDayTime!,
                        endOfDayTime: rsettings.endOfDayTime!,
                        lunchTime: rsettings.lunchTime!,
                        scrumTime: rsettings.scrumTime!,
                        minSleepDuration: rsettings.minSleepDuration!
        )
    }
    
    fileprivate func rsettingsFromSettings (_ settings: Settings) -> SSettings {
        
        let results: [SSettings] = queryWithPredicate(nil, sortingKeyPath: nil)
        var rsettings: SSettings? = results.first
        if rsettings == nil {
            rsettings = SSettings()
        }
        rsettings?.startOfDayEnabled = settings.startOfDayEnabled
        rsettings?.lunchEnabled = settings.lunchEnabled
        rsettings?.scrumEnabled = settings.scrumEnabled
        rsettings?.meetingEnabled = settings.meetingEnabled
        rsettings?.autoTrackEnabled = settings.autoTrackEnabled
        rsettings?.trackingMode = settings.trackingMode.rawValue
        rsettings?.startOfDayTime = settings.startOfDayTime
        rsettings?.endOfDayTime = settings.endOfDayTime
        rsettings?.lunchTime = settings.lunchTime
        rsettings?.scrumTime = settings.scrumTime
        rsettings?.minSleepDuration = settings.minSleepDuration
        
        return rsettings!
    }
}
