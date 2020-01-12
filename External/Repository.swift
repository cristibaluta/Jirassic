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

    func queryTask (withId objectId: String) -> Task?
    func queryTasks (startDate: Date, endDate: Date, predicate: NSPredicate?) -> [Task]
    func queryTasks (startDate: Date, endDate: Date, predicate: NSPredicate?, completion: @escaping ([Task], NSError?) -> Void)
    func queryUnsyncedTasks() -> [Task]
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void)
    func queryUpdates (_ completion: @escaping ([Task], [String], NSError?) -> Void)
    // Marks the Task as deleted. If permanently is true it will be removed from db
    func deleteTask (_ task: Task, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void))
    func deleteTask (objectId: String, completion: @escaping ((_ success: Bool) -> Void))
    // Save a task and returns the same task with a taskId generated if it didn't had. Return nil if task was not saved
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task?) -> Void))
    
}

protocol RepositorySettings {
    
    func settings() -> Settings
    func saveSettings (_ settings: Settings)
    
}

protocol RepositoryProjects {
    
    func projects() -> [Project]
    func queryProjects(_ completion: @escaping ((_ task: [Project]) -> Void))
    func saveProject (_ project: Project, completion: @escaping ((_ task: Project?) -> Void))
    func deleteProject (_ project: Project, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void))
    
}

typealias Repository = RepositoryUser & RepositoryTasks & RepositorySettings & RepositoryProjects
