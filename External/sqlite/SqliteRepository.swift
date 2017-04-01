//
//  CoreDataRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 15/04/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class SqliteRepository {
    
    fileprivate let databaseName = "Jirassic"
    fileprivate var db: SQLiteDB!
    
    init() {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let baseUrl = urls.last!
        let url = baseUrl.appendingPathComponent(databaseName)
        if !FileManager.default.fileExists(atPath: url.path) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
        let dbUrl = url.appendingPathComponent("\(databaseName).sqlite")
        RCLog(dbUrl)
        db = SQLiteDB(url: dbUrl)
        
        // Get current version
        let v = db.query(sql: "SELECT * FROM 'sversions';")
        RCLog(v)
        if v.count == 0 {
            // Create tables
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS sversions (db_version REAL);")
            let _ = db.execute(sql: "INSERT INTO sversions (db_version) values(1.0);")
            
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS stasks (lastModifiedDate DATETIME, creationDate DATETIME, startDate DATETIME, endDate DATETIME, notes TEXT, taskNumber TEXT, taskType INTEGER, objectId TEXT UNIQUE);")
            
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS ssettingss (startOfDayEnabled BOOL, lunchEnabled BOOL, scrumEnabled BOOL, meetingEnabled BOOL, autoTrackEnabled BOOL, trackingMode INTEGER, startOfDayTime DATETIME, endOfDayTime DATETIME, lunchTime DATETIME, scrumTime DATETIME, minSleepDuration DATETIME);")
            
            let _ = db.execute(sql: "CREATE TABLE IF NOT EXISTS susers (userId TEXT, email TEXT, lastSyncDate DATETIME, isLoggedIn BOOL);")
        }
    }
    
    convenience init (documentsDirectory: String) {
        self.init()
        let baseUrl = URL(fileURLWithPath: documentsDirectory)
        let url = baseUrl.appendingPathComponent("\(databaseName).sqlite")
        print(url)
        db = SQLiteDB(url: url)
    }
}

extension SqliteRepository {
    
    fileprivate func queryWithPredicate<T: SQLTable> (_ predicate: String?, sortingKeyPath: String?) -> [T] {
        
        var results = [T]()
        
        let resultsObjs = T.rows(filter: predicate ?? "", order: sortingKeyPath != nil ? "\(sortingKeyPath!) ASC" : "") as! [T]
        RCLog(resultsObjs)
        for result in resultsObjs {
            results.append(result)
        }
        
        return results
    }
}

extension SqliteRepository: RepositoryUser {
    
    func currentUser() -> User {
        
//        let userPredicate = NSPredicate(format: "isLoggedIn == YES")
//        let cusers: [RUser] = queryWithPredicate(userPredicate, sortDescriptors: nil)
//        if let cuser = cusers.last {
//            return User(isLoggedIn: true, email: cuser.email, userId: cuser.userId, lastSyncDate: cuser.lastSyncDate)
//        }
        
        return User(isLoggedIn: false, email: nil, userId: nil, lastSyncDate: nil)
    }
    
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to local Repository")
    }
    
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to local Repository")
    }
    
    func logout() {
    }
}

extension SqliteRepository: RepositoryTasks {
    
    func queryTasks (_ page: Int, completion: ([Task], NSError?) -> Void) {
        
        let results: [STask] = queryWithPredicate(nil, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)
        
        completion(tasks, nil)
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        
        let predicate = "datetime(endDate) BETWEEN datetime('\(day.startOfDay().YYYYMMddHHmmss())') AND datetime('\(day.endOfDay().YYYYMMddHHmmss())')"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: "endDate")
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func queryUnsyncedTasks() -> [Task] {
        
        let predicate = "lastModifiedDate == NULL"
        let results: [STask] = queryWithPredicate(predicate, sortingKeyPath: nil)
        let tasks = tasksFromSTasks(results)
        
        return tasks
    }
    
    func deleteTask (_ task: Task, completion: ((_ success: Bool) -> Void)) {
        
        let stask = staskFromTask(task)
        let deleted = stask.delete()
        RCLog("deleted \(deleted)")
        
        completion(deleted)
    }
    
    func saveTask (_ task: Task, completion: (_ success: Bool) -> Void) -> Task {
        
        let stask = staskFromTask(task)
        let saved = stask.save()
        RCLog("saved \(saved)")
        completion(saved == 1)
        
        return taskFromSTask(stask)
    }
    
    fileprivate func taskFromSTask (_ rtask: STask) -> Task {
        
        return Task(startDate: rtask.startDate,
                    endDate: rtask.endDate!,
                    notes: rtask.notes,
                    taskNumber: rtask.taskNumber,
                    taskType: TaskType(rawValue: rtask.taskType)!,
                    objectId: rtask.objectId!
        )
    }
    
    fileprivate func tasksFromSTasks (_ rtasks: [STask]) -> [Task] {
        
        var tasks = [Task]()
        for rtask in rtasks {
            tasks.append(self.taskFromSTask(rtask))
        }
        
        return tasks
    }
    
    fileprivate func staskFromTask (_ task: Task) -> STask {
        
        let taskPredicate = "objectId == '\(task.objectId)'"
        let tasks: [STask] = queryWithPredicate(taskPredicate, sortingKeyPath: nil)
        var stask: STask? = tasks.first
        if stask == nil {
            stask = STask()
        }
        if stask!.objectId == nil {
            stask!.objectId = task.objectId
        }
        
        return updatedSTask(stask!, withTask: task)
    }
    
    // Update only updatable properties. objectId can't be updated
    fileprivate func updatedSTask (_ rtask: STask, withTask task: Task) -> STask {
        
        rtask.taskNumber = task.taskNumber
        rtask.taskType = task.taskType.rawValue
        rtask.notes = task.notes
        rtask.startDate = task.startDate
        rtask.endDate = task.endDate
        
        return rtask
    }
}

extension SqliteRepository: RepositorySettings {
    
    func settings() -> Settings {
        
        let results: [SSettings] = queryWithPredicate(nil, sortingKeyPath: nil)
        var rsettings: SSettings? = results.first
        if rsettings == nil {
            rsettings = SSettings()
            rsettings?.startOfDayEnabled = true
            rsettings?.lunchEnabled = true
            rsettings?.scrumEnabled = true
            rsettings?.meetingEnabled = true
            rsettings?.autoTrackEnabled = true
            rsettings?.trackingMode = 1
            rsettings?.startOfDayTime = Date(hour: 9, minute: 0)
            rsettings?.endOfDayTime = Date(hour: 17, minute: 0)
            rsettings?.lunchTime = Date(hour: 13, minute: 0)
            rsettings?.scrumTime = Date(hour: 10, minute: 30)
            rsettings?.minSleepDuration = Date(hour: 0, minute: 13)
            
        }
        return settingsFromRSettings(rsettings!)
    }
    
    func saveSettings (_ settings: Settings) {
        
        let _ = rsettingsFromSettings(settings)
        
    }
    
    fileprivate func settingsFromRSettings (_ rsettings: SSettings) -> Settings {
        
        return Settings(startOfDayEnabled: rsettings.startOfDayEnabled,
                        lunchEnabled: rsettings.lunchEnabled,
                        scrumEnabled: rsettings.scrumEnabled,
                        meetingEnabled: rsettings.meetingEnabled,
                        autoTrackEnabled: rsettings.autoTrackEnabled,
                        trackingMode: TaskTrackingMode(rawValue: rsettings.trackingMode)!,
                        startOfDayTime: rsettings.startOfDayTime!,
                        endOfDayTime: rsettings.endOfDayTime!,
                        lunchTime: rsettings.lunchTime!,
                        scrumTime: rsettings.scrumTime!,
                        minSleepDuration: rsettings.minSleepDuration!
        )
    }
    
    fileprivate func rsettingsFromSettings (_ settings: Settings) -> SSettings {
        
        let results: [SSettings] = queryWithPredicate(nil, sortingKeyPath: nil)
        var rsettings: SSettings? = results.first
        if rsettings == nil {
            rsettings = SSettings()
        }
        rsettings?.startOfDayEnabled = settings.startOfDayEnabled
        rsettings?.lunchEnabled = settings.lunchEnabled
        rsettings?.scrumEnabled = settings.scrumEnabled
        rsettings?.meetingEnabled = settings.meetingEnabled
        rsettings?.autoTrackEnabled = settings.autoTrackEnabled
        rsettings?.trackingMode = settings.trackingMode.rawValue
        rsettings?.startOfDayTime = settings.startOfDayTime
        rsettings?.endOfDayTime = settings.endOfDayTime
        rsettings?.lunchTime = settings.lunchTime
        rsettings?.scrumTime = settings.scrumTime
        rsettings?.minSleepDuration = settings.minSleepDuration
        
        return rsettings!
    }
}
