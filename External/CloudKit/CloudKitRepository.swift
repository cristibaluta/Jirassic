//
//  CloudKitRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/06/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CloudKit
import RCLog

class CloudKitRepository {
    
    internal var user: User?
    internal let container = CKContainer(identifier: "iCloud.com.jirassic.macos")
    internal var privateDB: CKDatabase?
    internal var tasksZone: CloudKitZone?
    internal var projectsZone: CloudKitZone?
    
    init() {
        getUser { [weak self] (user) in
            if let user = user {
                self?.user = user
                self?.initDB()
            }
        }
    }
    
    func initDB() {
        
        privateDB = container.privateCloudDatabase
        guard let db = privateDB else {
            return
        }
        tasksZone = CloudKitZone(db: db, zoneName: "TasksZone")
        projectsZone = CloudKitZone(db: db, zoneName: "ProjectsZone")
    }

    internal func stringIdsFromCKRecordIds (_ ckrecords: [CKRecord.ID]) -> [String] {
        return ckrecords.map({ $0.recordName })
    }
}
