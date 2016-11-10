//
//  AddTask.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/10/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskInteractor: RepositoryInteractor {

    func saveTask (_ task: Task) {
        
        let savedTask = data.saveTask(task, completion: { (success: Bool) -> Void in
            
        })
        let _ = remoteRepository?.saveTask(savedTask, completion: { (success: Bool) -> Void in
            
        })
    }
    
    func deleteTask (_ task: Task) {
        
        data.deleteTask(task, completion: { (success: Bool) -> Void in
            
        })
        remoteRepository?.deleteTask(task, completion: { (success: Bool) -> Void in
            
        })
    }
}
