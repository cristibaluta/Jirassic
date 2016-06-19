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
    func loginWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void)
    func registerWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void)
    func logout()
    
    // MARK: Tasks
    func queryTasks (page: Int, completion: ([Task], NSError?) -> Void)
    func queryTasksInDay (day: NSDate) -> [Task]
    func queryUnsyncedTasks() -> [Task]
    func deleteTask (dataToDelete: Task, completion: ((success: Bool) -> Void))
    // Save a task and return the same task with a taskId generated if it didn't had
    func saveTask (theTask: Task, completion: ((success: Bool) -> Void)) -> Task
}
