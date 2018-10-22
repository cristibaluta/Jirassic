//
//  Repository.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

protocol RepositoryUser {
    
    func getUser (_ completion: @escaping ((_ user: User?) -> Void))
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void)
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void)
    func logout()
    
}

protocol RepositoryTasks {

    func queryTasks (startDate: Date, endDate: Date) -> [Task]
    func queryTasks (startDate: Date, endDate: Date, completion: @escaping ([Task], NSError?) -> Void)
    func queryUnsyncedTasks() -> [Task]
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void)
    func queryUpdates (_ completion: @escaping ([Task], [String], NSError?) -> Void)
    // Marks the Task as deleted. If permanently is true it will be removed from db
    func deleteTask (_ task: Task, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void))
    func deleteTask (objectId: String, completion: @escaping ((_ success: Bool) -> Void))
    // Save a task and returns the same task with a taskId generated if it didn't had
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task) -> Void))
    
}

protocol RepositorySettings {
    
    func settings() -> Settings
    func saveSettings (_ settings: Settings)
    
}

typealias Repository = RepositoryUser & RepositoryTasks & RepositorySettings
