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
            csettings = NSEntityDescription.insertNewObject(forEntityName: String(describing: CSettings.self),
                                                            into: managedObjectContext!) as? CSettings
            csettings?.startOfDayEnabled = 1
            csettings?.lunchEnabled = 1
            csettings?.scrumEnabled = 1
            csettings?.meetingEnabled = 1
            csettings?.autoTrackEnabled = 1
            csettings?.trackingMode = 1
            csettings?.startOfDayTime = Date(hour: 9, minute: 0)
            csettings?.endOfDayTime = Date(hour: 17, minute: 0)
            csettings?.lunchTime = Date(hour: 13, minute: 0)
            csettings?.scrumTime = Date(hour: 10, minute: 30)
            csettings?.minSleepDuration = Date(hour: 0, minute: 13)
            saveContext()
        }
        return settingsFromCSettings(csettings!)
    }
    
    func saveSettings (_ settings: Settings) {
        
        let _ = csettingsFromSettings(settings)
        saveContext()
    }
    
    fileprivate func settingsFromCSettings (_ csettings: CSettings) -> Settings {
        
        return Settings(startOfDayEnabled: csettings.startOfDayEnabled!.boolValue,
                        lunchEnabled: csettings.lunchEnabled!.boolValue,
                        scrumEnabled: csettings.scrumEnabled!.boolValue,
                        meetingEnabled: csettings.meetingEnabled!.boolValue,
                        autoTrackEnabled: csettings.autoTrackEnabled!.boolValue,
                        trackingMode: TaskTrackingMode(rawValue: csettings.trackingMode!.intValue)!,
                        startOfDayTime: csettings.startOfDayTime!,
                        endOfDayTime: csettings.endOfDayTime!,
                        lunchTime: csettings.lunchTime!,
                        scrumTime: csettings.scrumTime!,
                        minSleepDuration: csettings.minSleepDuration!
        )
    }
    
    fileprivate func csettingsFromSettings (_ settings: Settings) -> CSettings {
        
        let results: [CSettings] = queryWithPredicate(nil, sortDescriptors: nil)
        var csettings: CSettings? = results.first
        if csettings == nil {
            csettings = NSEntityDescription.insertNewObject(forEntityName: String(describing: CSettings.self),
                                                            into: managedObjectContext!) as? CSettings
        }
        csettings?.startOfDayEnabled = NSNumber(value: settings.startOfDayEnabled)
        csettings?.lunchEnabled = NSNumber(value: settings.lunchEnabled)
        csettings?.scrumEnabled = NSNumber(value: settings.scrumEnabled)
        csettings?.meetingEnabled = NSNumber(value: settings.meetingEnabled)
        csettings?.autoTrackEnabled = NSNumber(value: settings.autoTrackEnabled)
        csettings?.trackingMode = NSNumber(value: settings.trackingMode.rawValue)
        csettings?.startOfDayTime = settings.startOfDayTime
        csettings?.endOfDayTime = settings.endOfDayTime
        csettings?.lunchTime = settings.lunchTime
        csettings?.scrumTime = settings.scrumTime
        csettings?.minSleepDuration = settings.minSleepDuration
        
        return csettings!
    }
}
