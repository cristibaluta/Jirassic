//
//  CoreDataRepository+Settings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataRepository: RepositorySettings {
    
    func settings() -> Settings {
        
        let results: [CSettings] = queryWithPredicate(nil, sortDescriptors: nil)
        var csettings: CSettings? = results.first
        if csettings == nil {
            // Default values
            csettings = NSEntityDescription.insertNewObject(forEntityName: String(describing: CSettings.self),
                                                            into: managedObjectContext!) as? CSettings
            csettings?.autotrack = 1
            csettings?.autotrackingMode = 1
            csettings?.trackLunch = 1
            csettings?.trackScrum = 1
            csettings?.trackMeetings = 1
            csettings?.trackCodeReviews = 1
            csettings?.trackWastedTime = 1
            csettings?.trackStartOfDay = 1
            csettings?.enableBackup = 1
            csettings?.startOfDayTime = Date(hour: 9, minute: 0)
            csettings?.endOfDayTime = Date(hour: 17, minute: 0)
            csettings?.lunchTime = Date(hour: 13, minute: 0)
            csettings?.scrumTime = Date(hour: 10, minute: 30)
            csettings?.minSleepDuration = NSNumber(value: 13)
            csettings?.minCodeRevDuration = NSNumber(value: 3)
            csettings?.minWasteDuration = NSNumber(value: 5)
            csettings?.codeRevLink = ""
            csettings?.wasteLinks = ["facebook.com", "youtube.com", "twitter.com"]
            
            saveContext()
        }
        return settingsFromCSettings(csettings!)
    }
    
    func saveSettings (_ settings: Settings) {
        
        let _ = csettingsFromSettings(settings)
        saveContext()
    }
    
    fileprivate func settingsFromCSettings (_ csettings: CSettings) -> Settings {
        
        return Settings(
            
            autotrack: csettings.autotrack!.boolValue,
            autotrackingMode: TrackingMode(rawValue: csettings.autotrackingMode!.intValue)!,
            trackLunch: csettings.trackLunch!.boolValue,
            trackScrum: csettings.trackScrum!.boolValue,
            trackMeetings: csettings.trackMeetings!.boolValue,
            trackStartOfDay: csettings.trackStartOfDay!.boolValue,
            enableBackup: csettings.enableBackup!.boolValue,
            startOfDayTime: csettings.startOfDayTime!,
            endOfDayTime: csettings.endOfDayTime!,
            lunchTime: csettings.lunchTime!,
            scrumTime: csettings.scrumTime!,
            minSleepDuration: csettings.minSleepDuration!.intValue,
            settingsBrowser: SettingsBrowser(
                trackCodeReviews: csettings.trackCodeReviews!.boolValue,
                trackWastedTime: csettings.trackWastedTime!.boolValue,
                minCodeRevDuration: csettings.minCodeRevDuration!.intValue,
                codeRevLink: csettings.codeRevLink!,
                minWasteDuration: csettings.minWasteDuration!.intValue,
                wasteLinks: csettings.wasteLinks!
            )
        )
    }
    
    fileprivate func csettingsFromSettings (_ settings: Settings) -> CSettings {
        
        let results: [CSettings] = queryWithPredicate(nil, sortDescriptors: nil)
        var csettings: CSettings? = results.first
        if csettings == nil {
            csettings = NSEntityDescription.insertNewObject(forEntityName: String(describing: CSettings.self),
                                                            into: managedObjectContext!) as? CSettings
        }
        
        csettings?.autotrack = NSNumber(value: settings.autotrack)
        csettings?.autotrackingMode = NSNumber(value: settings.autotrackingMode.rawValue)
        csettings?.trackLunch = NSNumber(value: settings.trackLunch)
        csettings?.trackScrum = NSNumber(value: settings.trackScrum)
        csettings?.trackMeetings = NSNumber(value: settings.trackMeetings)
        csettings?.trackCodeReviews = NSNumber(value: settings.settingsBrowser.trackCodeReviews)
        csettings?.trackWastedTime = NSNumber(value: settings.settingsBrowser.trackWastedTime)
        csettings?.trackStartOfDay = NSNumber(value: settings.trackStartOfDay)
        csettings?.enableBackup = NSNumber(value: settings.enableBackup)
        csettings?.startOfDayTime = settings.startOfDayTime
        csettings?.endOfDayTime = settings.endOfDayTime
        csettings?.lunchTime = settings.lunchTime
        csettings?.scrumTime = settings.scrumTime
        csettings?.minSleepDuration = NSNumber(value: settings.minSleepDuration)
        csettings?.minCodeRevDuration = NSNumber(value: settings.settingsBrowser.minCodeRevDuration)
        csettings?.codeRevLink = settings.settingsBrowser.codeRevLink
        csettings?.minWasteDuration = NSNumber(value: settings.settingsBrowser.minWasteDuration)
        csettings?.wasteLinks = settings.settingsBrowser.wasteLinks
        
        return csettings!
    }
}
