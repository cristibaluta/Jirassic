//
//  AddTask.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/10/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class SaveTaskInteractor: RepositoryInteractor {

    func saveTask (task: Task) {
        
        localRepository.saveTask(task, completion: { (success: Bool) -> Void in
            
        })
        remoteRepository.saveTask(task, completion: { (success: Bool) -> Void in
            
        })
    }
}
