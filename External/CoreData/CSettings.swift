//
//  CSettings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CoreData

class CSettings: NSManagedObject {
    
    @NSManaged var autoTrackStartOfDay: NSNumber?
    @NSManaged var autoTrackLunch: NSNumber?
    @NSManaged var autoTrackScrum: NSNumber?
    @NSManaged var autoTrackMeetings: NSNumber?
    
    @NSManaged var startOfDayTime: Date?
    @NSManaged var lunchTime: Date?
    @NSManaged var scrumMeetingTime: Date?
    @NSManaged var minMeetingDuration: Date?
}
