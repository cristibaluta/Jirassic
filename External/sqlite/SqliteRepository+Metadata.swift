//
//  SqliteRepository+Metadata.swift
//  Jirassic
//
//  Created by Cristian Baluta on 13/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation

extension SqliteRepository: RepositoryMetadata {
    
    func tasksLastSyncDate() -> Date? { return metadata().tasksLastSyncDate }
    func projectsLastSyncDate() -> Date? { return metadata().projectsLastSyncDate }
    func tasksLastSyncToken() -> String? { return metadata().tasksLastSyncToken }
    func projectsLastSyncToken() -> String? { return metadata().projectsLastSyncToken }
    
    func set(tasksLastSyncDate: Date?) {
        let meta =  metadata()
        meta.tasksLastSyncDate = tasksLastSyncDate
        saveMetadata(meta)
    }
    func set(projectsLastSyncDate: Date?) {
        let meta =  metadata()
        meta.projectsLastSyncDate = projectsLastSyncDate
        saveMetadata(meta)
    }
    func set(tasksLastSyncToken: String?) {
        let meta =  metadata()
        meta.tasksLastSyncToken = tasksLastSyncToken
        saveMetadata(meta)
    }
    func set(projectsLastSyncToken: String?) {
        let meta =  metadata()
        meta.projectsLastSyncToken = projectsLastSyncToken
        saveMetadata(meta)
    }
    
    
    private func metadata() -> SMetadata {
        
        let results: [SMetadata] = queryWithPredicate(nil, sortingKeyPath: nil)
        guard let smetadata = results.first else {
            let smetadata = SMetadata()
            smetadata.tasksLastSyncDate = nil
            smetadata.projectsLastSyncDate = nil
            smetadata.tasksLastSyncToken = nil
            smetadata.projectsLastSyncToken = nil
            return smetadata
        }

        return smetadata
    }
    
    
    func saveMetadata (_ metadata: SMetadata) {
        _ = metadata.save()
    }
    
}
