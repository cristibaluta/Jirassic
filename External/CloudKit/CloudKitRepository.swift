//
//  FirebaseRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/06/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitRepository {
    
    internal var tasks = [Task]()
    internal var user: User?
    internal let privateDB = CKContainer.default().privateCloudDatabase
    internal let zoneId = CKRecordZoneID(zoneName: "tasksZone", ownerName: CKOwnerDefaultName)
    internal let preferences = RCPreferences<LocalPreferences>()
    
    init() {
        CKContainer.default().accountStatus(completionHandler: { (status, error) in
            RCLog(status.rawValue)
            RCLogErrorO(error)
        })
    }
}

extension CloudKitRepository {
    
    func fetchChangedRecords (token: CKServerChangeToken?) {
        
        let op = CKFetchRecordChangesOperation(recordZoneID: zoneId, previousServerChangeToken: token)
        
        op.recordChangedBlock = { record in
            RCLog(record)
        }
        
        op.recordWithIDWasDeletedBlock = { recordID in
            RCLog(recordID)
        }
        
        op.fetchRecordChangesCompletionBlock = { serverChangeToken, clientChangeToken, error in
            
            RCLogO(serverChangeToken)
            RCLogO(clientChangeToken)
            RCLogErrorO(error)
            if let err = error {
            }
            
            if op.moreComing {
                self.fetchChangedRecords(token: serverChangeToken)
            }
        }
        
        privateDB.add(op)
        
        //        let predicate = NSPredicate(format: "TRUEPREDICATE")
//        let lastSyncDate: Date = preferences.get(.lastIcloudSync)
//        let predicate = NSPredicate(format: "creationDate >= %@", lastSyncDate as CVarArg)
//        let query = CKQuery(recordType: "Task", predicate: predicate)
//        privateDB.perform(query, inZoneWith: nil) { (results: [CKRecord]?, error) in
//            
//            RCLogErrorO(error)
//            
//            if let results = results {
//                for record in results {
//                    RCLogO(record)
//                    self.privateDB.delete(withRecordID: record.recordID, completionHandler: { (res, err) in
//                        RCLogO(res)
//                        RCLogErrorO(err)
//                    })
//                }
//            }
//        }
    }
}
