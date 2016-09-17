//
//  Repository.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

protocol Repository {
    
    // MARK: User
    func currentUser() -> User
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void)
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void)
    func logout()
    
    // MARK: Tasks
    func queryTasks (_ page: Int, completion: ([Task], NSError?) -> Void)
    func queryTasksInDay (_ day: Date) -> [Task]
    func queryUnsyncedTasks() -> [Task]
    func deleteTask (_ dataToDelete: Task, completion: ((_ success: Bool) -> Void))
    // Save a task and return the same task with a taskId generated if it didn't had
    func saveTask (_ theTask: Task, completion: ((_ success: Bool) -> Void)) -> Task
    
    // MARK: Settings
    func settings() -> Settings
    func saveSettings (_ settings: Settings)
}
