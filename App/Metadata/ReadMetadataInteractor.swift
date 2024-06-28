//
//  ReadMetadataInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit

class ReadMetadataInteractor: RepositoryInteractor {
    
    init() {
        super.init(repository: localRepository, remoteRepository: nil)
    }
    
    func tasksLastSyncDate() -> Date? {
        return repository.tasksLastSyncDate()
    }
    func projectsLastSyncDate() -> Date? {
        return repository.projectsLastSyncDate()
    }
    
    func tasksLastSyncToken() -> CKServerChangeToken? {
        let stringToken = repository.tasksLastSyncToken()
        return token(from: stringToken)
    }
    func projectsLastSyncToken() -> CKServerChangeToken? {
        let stringToken = repository.projectsLastSyncToken()
        return token(from: stringToken)
    }
    
    private func token (from stringToken: String?) -> CKServerChangeToken? {
        
        guard let string = stringToken,
              let data = Data(base64Encoded: string),
              let token = try? NSKeyedUnarchiver.unarchivedObject(ofClass: CKServerChangeToken.self, from: data) else {
            return nil
        }
        
        return token
    }
}
