//
//  SQLiteMigrator.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

enum SQLiteSchemaVersion: Int {
    case v1 = 1
}

class SQLiteSchema {
    
    fileprivate let expectedVersion: SQLiteSchemaVersion = .v1
    
    init (db: SQLiteDB) {
        
        RCLog(db.version)
        if db.version != expectedVersion.rawValue {
            migrate(db: db, toVersion: expectedVersion)
            UserDefaults.standard.serverChangeToken = nil
        }
    }
}

extension SQLiteSchema {
    
    func migrate (db: SQLiteDB, toVersion version: SQLiteSchemaVersion) {
        
        switch version {
        case .v1:
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS stasks (lastModifiedDate DATETIME, markedForDeletion BOOL DEFAULT 0, startDate DATETIME, endDate DATETIME, notes TEXT, taskNumber TEXT, taskTitle TEXT, taskType INTEGER NOT NULL, objectId varchar(30) PRIMARY KEY);")
            
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS ssettingss (autotrack BOOL, autotrackingMode INTEGER, trackLunch BOOL, trackScrum BOOL, trackMeetings BOOL, trackCodeReviews BOOL, trackWastedTime BOOL, trackStartOfDay BOOL, enableBackup BOOL, startOfDayTime DATETIME, endOfDayTime DATETIME, lunchTime DATETIME, scrumTime DATETIME, minSleepDuration INTEGER, minCodeRevDuration INTEGER, codeRevLink TEXT, minWasteDuration INTEGER, wasteLinks TEXT, i INTEGER NOT NULL PRIMARY KEY);")
            
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS susers (userId TEXT, email TEXT, lastSyncDate DATETIME, isLoggedIn BOOL, i INTEGER NOT NULL PRIMARY KEY);")
            break
        }
        db.version = version.rawValue
    }
}
