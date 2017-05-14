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
    
    @NSManaged var autotrack: NSNumber?
    @NSManaged var autotrackingMode: NSNumber?
    @NSManaged var trackLunch: NSNumber?
    @NSManaged var trackScrum: NSNumber?
    @NSManaged var trackMeetings: NSNumber?
    @NSManaged var trackCodeReviews: NSNumber?
    @NSManaged var trackWastedTime: NSNumber?
    @NSManaged var trackStartOfDay: NSNumber?
    @NSManaged var enableBackup: NSNumber?
    
    @NSManaged var startOfDayTime: Date?
    @NSManaged var endOfDayTime: Date?
    @NSManaged var lunchTime: Date?
    @NSManaged var scrumTime: Date?
    @NSManaged var minSleepDuration: Date?
    @NSManaged var minCodeRevDuration: Date?
    @NSManaged var codeRevLink: String?
    @NSManaged var minWasteDuration: Date?
    @NSManaged var wasteLinks: [String]?
    
}
