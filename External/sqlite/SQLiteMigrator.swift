//
//  SQLiteMigrator.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

enum SQLiteSchemaVersion: Double {
    case v1_0 = 1.0
}

class SQLiteMigrator {
    
    init (db: SQLiteDB) {
        
        // Get current version
        let v = db.query(sql: "SELECT * FROM 'sversions';")
        if v.count == 0 {
            migrate(db: db, toVersion: .v1_0)
        }
    }
}

extension SQLiteMigrator {
    
    func migrate (db: SQLiteDB, toVersion version: SQLiteSchemaVersion) {
        
        switch version {
        case .v1_0:
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS sversions (db_version REAL);")
            
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS stasks (lastModifiedDate DATETIME, deleted BOOL, startDate DATETIME, endDate DATETIME, notes TEXT, taskNumber TEXT, taskType INTEGER NOT NULL, objectId varchar(100) PRIMARY KEY);")
            
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS ssettingss (startOfDayEnabled BOOL, lunchEnabled BOOL, scrumEnabled BOOL, meetingEnabled BOOL, autoTrackEnabled BOOL, trackingMode INTEGER, startOfDayTime DATETIME, endOfDayTime DATETIME, lunchTime DATETIME, scrumTime DATETIME, minSleepDuration DATETIME, i INTEGER NOT NULL PRIMARY KEY);")
            
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS susers (userId TEXT, email TEXT, lastSyncDate DATETIME, isLoggedIn BOOL, i INTEGER NOT NULL PRIMARY KEY);")
            break
        }
        let _ = db.execute(sql: "INSERT INTO sversions (db_version) values(\(version.rawValue));")
    }
}
