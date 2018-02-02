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
        RCLog(">>>>>>>>>> get startOfDayTime \(ssettings?.startOfDayTime)")
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
            ssettings?.startOfDayTime = Date(date: Date(timeIntervalSince1970: 0), hour: 9, minute: 0)
            ssettings?.endOfDayTime = Date(date: Date(timeIntervalSince1970: 0), hour: 17, minute: 0)
            ssettings?.lunchTime = Date(date: Date(timeIntervalSince1970: 0), hour: 13, minute: 0)
            ssettings?.scrumTime = Date(date: Date(timeIntervalSince1970: 0), hour: 10, minute: 30)
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
        RCLog(">>>>>>>>>> SAVE startOfDayTime \(ssettings.startOfDayTime)")
        print( ssettings.save())
        RCLog(">>>>>>>>>> SAVED startOfDayTime \(self.settings().settingsTracking.startOfDayTime)")
        
    }
    
    fileprivate func settingsFromSSettings (_ ssettings: SSettings) -> Settings {
        
        return Settings(enableBackup: ssettings.enableBackup,
                        settingsTracking: SettingsTracking(
                            autotrack: ssettings.autotrack,
                            autotrackingMode: TrackingMode(rawValue: ssettings.autotrackingMode)!,
                            trackLunch: ssettings.trackLunch,
                            trackScrum: ssettings.trackScrum,
                            trackMeetings: ssettings.trackMeetings,
                            trackStartOfDay: ssettings.trackStartOfDay,
                            startOfDayTime: ssettings.startOfDayTime!,
                            endOfDayTime: ssettings.endOfDayTime!,
                            lunchTime: ssettings.lunchTime!,
                            scrumTime: ssettings.scrumTime!,
                            minSleepDuration: ssettings.minSleepDuration
                        ),
                        settingsBrowser: SettingsBrowser(
                            trackCodeReviews: ssettings.trackCodeReviews,
                            trackWastedTime: ssettings.trackWastedTime,
                            minCodeRevDuration: ssettings.minCodeRevDuration,
                            codeRevLink: ssettings.codeRevLink!,
                            minWasteDuration: ssettings.minWasteDuration,
                            wasteLinks: ssettings.wasteLinks!.toArray()
                        )
        )
    }
    
    fileprivate func ssettingsFromSettings (_ settings: Settings) -> SSettings {
        
        let results: [SSettings] = queryWithPredicate(nil, sortingKeyPath: nil)
        var ssettings: SSettings? = results.first
        if ssettings == nil {
            ssettings = SSettings()
        }
        ssettings?.autotrack = settings.settingsTracking.autotrack
        ssettings?.autotrackingMode = settings.settingsTracking.autotrackingMode.rawValue
        ssettings?.trackLunch = settings.settingsTracking.trackLunch
        ssettings?.trackScrum = settings.settingsTracking.trackScrum
        ssettings?.trackMeetings = settings.settingsTracking.trackMeetings
        ssettings?.trackCodeReviews = settings.settingsBrowser.trackCodeReviews
        ssettings?.trackWastedTime = settings.settingsBrowser.trackWastedTime
        ssettings?.trackStartOfDay = settings.settingsTracking.trackStartOfDay
        ssettings?.enableBackup = settings.enableBackup
        ssettings?.startOfDayTime = settings.settingsTracking.startOfDayTime
        ssettings?.endOfDayTime = settings.settingsTracking.endOfDayTime
        ssettings?.lunchTime = settings.settingsTracking.lunchTime
        ssettings?.scrumTime = settings.settingsTracking.scrumTime
        ssettings?.minSleepDuration = settings.settingsTracking.minSleepDuration
        ssettings?.minCodeRevDuration = settings.settingsBrowser.minCodeRevDuration
        ssettings?.codeRevLink = settings.settingsBrowser.codeRevLink
        ssettings?.minWasteDuration = settings.settingsBrowser.minWasteDuration
        ssettings?.wasteLinks = settings.settingsBrowser.wasteLinks.toString()
        
        return ssettings!
    }
}
