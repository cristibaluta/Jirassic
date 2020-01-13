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
    case v2 = 2

    static func allVersions() -> [SQLiteSchemaVersion] {
        return [.v1, .v2]
    }
}

class UpdateSchemaInteractor {

    func execute (with db: SQLiteDB) {
        guard let expectedVersion = SQLiteSchemaVersion.allVersions().last, db.version != expectedVersion.rawValue else {
            return
        }
        for version in SQLiteSchemaVersion.allVersions() {
            guard version.rawValue > db.version else {
                /// Skip versions already executed
                continue
            }
            migrate(db: db, toVersion: version)
        }
    }

    private func migrate (db: SQLiteDB, toVersion version: SQLiteSchemaVersion) {
        
        switch version {
            case .v1:
            /// Tasks table
            _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS stasks (lastModifiedDate DATETIME, markedForDeletion BOOL DEFAULT 0, startDate DATETIME, endDate DATETIME, notes TEXT, taskNumber TEXT, taskTitle TEXT, taskType INTEGER NOT NULL, objectId varchar(30) PRIMARY KEY);")
            /// Settings table
            _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS ssettingss (autotrack BOOL, autotrackingMode INTEGER, trackLunch BOOL, trackScrum BOOL, trackMeetings BOOL, trackCodeReviews BOOL, trackWastedTime BOOL, trackStartOfDay BOOL, enableBackup BOOL, startOfDayTime DATETIME, endOfDayTime DATETIME, lunchTime DATETIME, scrumTime DATETIME, minSleepDuration INTEGER, minCodeRevDuration INTEGER, codeRevLink TEXT, minWasteDuration INTEGER, wasteLinks TEXT, i INTEGER NOT NULL PRIMARY KEY);")
            /// Users table
            _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS susers (userId TEXT, email TEXT, lastSyncDate DATETIME, isLoggedIn BOOL, i INTEGER NOT NULL PRIMARY KEY);")

            case .v2:
            /// Edit Tasks table
            _ = db.execute(sql: "ALTER TABLE stasks ADD COLUMN projectId varchar(30);")
            /// Projects table
            _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS sprojects (objectId varchar(30) PRIMARY KEY, lastModifiedDate DATETIME, title TEXT, jiraBaseUrl TEXT, jiraUser TEXT, jiraProject TEXT, jiraIssue TEXT, gitBaseUrls TEXT, gitUsers TEXT, taskNumberPrefix TEXT);")
            /// Metadata table
            _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS smetadata (i INTEGER NOT NULL PRIMARY KEY, tasksLastSyncDate DATETIME, projectsLastSyncDate DATETIME, tasksLastSyncToken TEXT, projectsLastSyncToken TEXT);")
        }
        db.version = version.rawValue
    }
}
