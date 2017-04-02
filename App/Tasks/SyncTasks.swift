//
//  SyncTasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

class SyncTasks {
    
    let localRepository: Repository!
    let remoteRepository: Repository!
    
    init (localRepository: Repository, remoteRepository: Repository) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }
    
    func start (_ completion: ((_ hasIncomingChanges: Bool) -> Void)?) {
        
        let unsyncedTasks = localRepository.queryUnsyncedTasks()
        
        remoteRepository.queryTasks(0, completion: { (tasks, error) in
            completion?(tasks.count > 0)
        })
    }
}
