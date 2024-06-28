//
//  CoreDataRepository+Metadata.swift
//  Jirassic
//
//  Created by Cristian Baluta on 28.06.2024.
//  Copyright © 2024 Imagin soft. All rights reserved.
//

import Foundation

extension CoreDataRepository: RepositoryMetadata {

    func tasksLastSyncDate() -> Date? { return nil }
    func projectsLastSyncDate() -> Date? { return nil }
    func tasksLastSyncToken() -> String? { return nil }
    func projectsLastSyncToken() -> String? { return nil }

    func set(tasksLastSyncDate: Date?) {
    }
    func set(projectsLastSyncDate: Date?) {
    }
    func set(tasksLastSyncToken: String?) {
    }
    func set(projectsLastSyncToken: String?) {
    }

}
