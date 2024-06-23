//
//  CloudKitRepository+Metadata.swift
//  Jirassic
//
//  Created by Cristian Baluta on 13/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation

extension CloudKitRepository: RepositoryMetadata {
    
    func tasksLastSyncDate() -> Date? { fatalError("This method is not applicable to CloudKitRepository") }
    func projectsLastSyncDate() -> Date? { fatalError("This method is not applicable to CloudKitRepository") }
    func tasksLastSyncToken() -> String? { fatalError("This method is not applicable to CloudKitRepository") }
    func projectsLastSyncToken() -> String? { fatalError("This method is not applicable to CloudKitRepository") }
    func set(tasksLastSyncDate: Date?) { fatalError("This method is not applicable to CloudKitRepository") }
    func set(projectsLastSyncDate: Date?) { fatalError("This method is not applicable to CloudKitRepository") }
    func set(tasksLastSyncToken: String?) { fatalError("This method is not applicable to CloudKitRepository") }
    func set(projectsLastSyncToken: String?) { fatalError("This method is not applicable to CloudKitRepository") }
    
}
