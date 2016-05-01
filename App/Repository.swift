//
//  Repository.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

protocol Repository {
	
    func currentUser() -> User
    func loginWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void)
    func registerWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void)
    func logout()
    func queryTasks (page: Int, completion: ([Task], NSError?) -> Void)
    func queryTasksInDay (day: NSDate) -> [Task]
	func queryUnsyncedTasks() -> [Task]
    func deleteTask (dataToDelete: Task)
	func saveTask (theTask: Task, completion: ((success: Bool) -> Void))
}
