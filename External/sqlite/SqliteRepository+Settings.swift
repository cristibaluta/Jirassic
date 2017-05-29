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
            // Default values
            ssettings = SSettings()
            ssettings?.autotrack = true
            ssettings?.autotrackingMode = 1
            ssettings?.trackLunch = true
            ssettings?.trackScrum = true
            ssettings?.trackMeetings = true
            ssettings?.trackCodeReviews = true
            ssettings?.trackWastedTime = true
            ssettings?.trackStartOfDay = true
            ssettings?.enableBackup = true
            ssettings?.startOfDayTime = Date(hour: 9, minute: 0)
            ssettings?.endOfDayTime = Date(hour: 17, minute: 0)
            ssettings?.lunchTime = Date(hour: 13, minute: 0)
            ssettings?.scrumTime = Date(hour: 10, minute: 30)
            ssettings?.minSleepDuration = 13
            ssettings?.minCodeRevDuration = 2
            ssettings?.minWasteDuration = 5
            ssettings?.codeRevLink = "(http|https)://(.+)/projects/(.+)/repos/(.+)/pull-requests"
            ssettings?.wasteLinks = "facebook.com,youtube.com,twitter.com"
        }
        
        return settingsFromSSettings(ssettings!)
    }
    
    func saveSettings (_ settings: Settings) {
        
        let ssettings = ssettingsFromSettings(settings)
        print( ssettings.save())
        
    }
    
    fileprivate func settingsFromSSettings (_ ssettings: SSettings) -> Settings {
        
        return Settings(autotrack: ssettings.autotrack,
                        autotrackingMode: TrackingMode(rawValue: ssettings.autotrackingMode)!,
                        trackLunch: ssettings.trackLunch,
                        trackScrum: ssettings.trackScrum,
                        trackMeetings: ssettings.trackMeetings,
                        trackCodeReviews: ssettings.trackCodeReviews,
                        trackWastedTime: ssettings.trackWastedTime,
                        trackStartOfDay: ssettings.trackStartOfDay,
                        enableBackup: ssettings.enableBackup,
                        startOfDayTime: ssettings.startOfDayTime!,
                        endOfDayTime: ssettings.endOfDayTime!,
                        lunchTime: ssettings.lunchTime!,
                        scrumTime: ssettings.scrumTime!,
                        minSleepDuration: ssettings.minSleepDuration,
                        minCodeRevDuration: ssettings.minCodeRevDuration,
                        codeRevLink: ssettings.codeRevLink!,
                        minWasteDuration: ssettings.minWasteDuration,
                        wasteLinks: ssettings.wasteLinks!.toArray()
        )
    }
    
    fileprivate func ssettingsFromSettings (_ settings: Settings) -> SSettings {
        
        let results: [SSettings] = queryWithPredicate(nil, sortingKeyPath: nil)
        var ssettings: SSettings? = results.first
        if ssettings == nil {
            ssettings = SSettings()
        }
        ssettings?.autotrack = settings.autotrack
        ssettings?.autotrackingMode = settings.autotrackingMode.rawValue
        ssettings?.trackLunch = settings.trackLunch
        ssettings?.trackScrum = settings.trackScrum
        ssettings?.trackMeetings = settings.trackMeetings
        ssettings?.trackCodeReviews = settings.trackCodeReviews
        ssettings?.trackWastedTime = settings.trackWastedTime
        ssettings?.trackStartOfDay = settings.trackStartOfDay
        ssettings?.enableBackup = settings.enableBackup
        ssettings?.startOfDayTime = settings.startOfDayTime
        ssettings?.endOfDayTime = settings.endOfDayTime
        ssettings?.lunchTime = settings.lunchTime
        ssettings?.scrumTime = settings.scrumTime
        ssettings?.minSleepDuration = settings.minSleepDuration
        ssettings?.minCodeRevDuration = settings.minCodeRevDuration
        ssettings?.codeRevLink = settings.codeRevLink
        ssettings?.minWasteDuration = settings.minWasteDuration
        ssettings?.wasteLinks = settings.wasteLinks.toString()
        
        return ssettings!
    }
}
