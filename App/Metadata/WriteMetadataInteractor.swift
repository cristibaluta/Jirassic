//
//  WriteMetadataInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit

class WriteMetadataInteractor: RepositoryInteractor {
    
    init() {
        super.init(repository: localRepository, remoteRepository: nil)
    }
    
    func set (tasksLastSyncDate: Date?) {
        repository.set(tasksLastSyncDate: tasksLastSyncDate)
    }
    func set (projectsLastSyncDate: Date?) {
        repository.set(tasksLastSyncDate: projectsLastSyncDate)
    }
    
    func set (tasksLastSyncToken: CKServerChangeToken?) {
        repository.set(tasksLastSyncToken: string(from: tasksLastSyncToken))
    }
    func set (projectsLastSyncToken: CKServerChangeToken?) {
        repository.set(tasksLastSyncToken: string(from: projectsLastSyncToken))
    }
    
    private func string (from token: CKServerChangeToken?) -> String? {
        
        guard let token = token else {
            return nil
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: token)
        let string = data.base64EncodedString()
        return string
    }
}
