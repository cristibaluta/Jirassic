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
    
    @NSManaged var autoTrackLunch: NSNumber?
    @NSManaged var autoTrackScrum: NSNumber?
    @NSManaged var showSuggestions: NSNumber?
    @NSManaged var lunchTime: Date?
    @NSManaged var scrumMeetingTime: Date?
    @NSManaged var startDayTime: Date?
}
