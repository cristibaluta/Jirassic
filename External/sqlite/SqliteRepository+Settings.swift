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
        var ssettings: SSettings? = results.first
        if ssettings == nil {
            ssettings = SSettings()
            ssettings?.startOfDayEnabled = true
            ssettings?.lunchEnabled = true
            ssettings?.scrumEnabled = true
            ssettings?.meetingEnabled = true
            ssettings?.autoTrackEnabled = true
            ssettings?.trackingMode = 1
            ssettings?.startOfDayTime = Date(hour: 9, minute: 0)
            ssettings?.endOfDayTime = Date(hour: 17, minute: 0)
            ssettings?.lunchTime = Date(hour: 13, minute: 0)
            ssettings?.scrumTime = Date(hour: 10, minute: 30)
            ssettings?.minSleepDuration = Date(hour: 0, minute: 13)
        }
        return settingsFromSSettings(ssettings!)
    }
    
    func saveSettings (_ settings: Settings) {
        
        let _ = ssettingsFromSettings(settings)
        
    }
    
    fileprivate func settingsFromSSettings (_ ssettings: SSettings) -> Settings {
        
        return Settings(startOfDayEnabled: ssettings.startOfDayEnabled,
                        lunchEnabled: ssettings.lunchEnabled,
                        scrumEnabled: ssettings.scrumEnabled,
                        meetingEnabled: ssettings.meetingEnabled,
                        autoTrackEnabled: ssettings.autoTrackEnabled,
                        trackingMode: TaskTrackingMode(rawValue: ssettings.trackingMode)!,
                        startOfDayTime: ssettings.startOfDayTime!,
                        endOfDayTime: ssettings.endOfDayTime!,
                        lunchTime: ssettings.lunchTime!,
                        scrumTime: ssettings.scrumTime!,
                        minSleepDuration: ssettings.minSleepDuration!
        )
    }
    
    fileprivate func ssettingsFromSettings (_ settings: Settings) -> SSettings {
        
        let results: [SSettings] = queryWithPredicate(nil, sortingKeyPath: nil)
        var ssettings: SSettings? = results.first
        if ssettings == nil {
            ssettings = SSettings()
        }
        ssettings?.startOfDayEnabled = settings.startOfDayEnabled
        ssettings?.lunchEnabled = settings.lunchEnabled
        ssettings?.scrumEnabled = settings.scrumEnabled
        ssettings?.meetingEnabled = settings.meetingEnabled
        ssettings?.autoTrackEnabled = settings.autoTrackEnabled
        ssettings?.trackingMode = settings.trackingMode.rawValue
        ssettings?.startOfDayTime = settings.startOfDayTime
        ssettings?.endOfDayTime = settings.endOfDayTime
        ssettings?.lunchTime = settings.lunchTime
        ssettings?.scrumTime = settings.scrumTime
        ssettings?.minSleepDuration = settings.minSleepDuration
        
        return ssettings!
    }
}
