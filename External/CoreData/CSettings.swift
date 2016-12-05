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
    
    @NSManaged var startOfDayEnabled: NSNumber?
    @NSManaged var lunchEnabled: NSNumber?
    @NSManaged var scrumEnabled: NSNumber?
    @NSManaged var meetingEnabled: NSNumber?
    @NSManaged var autoTrackEnabled: NSNumber?
    @NSManaged var trackingMode: NSNumber?
    
    @NSManaged var startOfDayTime: Date?
    @NSManaged var endOfDayTime: Date?
    @NSManaged var lunchTime: Date?
    @NSManaged var scrumTime: Date?
    @NSManaged var minSleepDuration: Date?
    
}
