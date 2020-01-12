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
    internal var customZone: CKRecordZone?
    
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
        customZone = CKRecordZone(zoneName: "TasksZone")
        
        privateDB!.save(customZone!) { (recordZone, err) in
            RCLogO(recordZone)
            RCLogErrorO(err)
        }
    }
}

extension CloudKitRepository {
    
    func fetchChangedRecords (token: CKServerChangeToken?, 
                              previousRecords: [CKRecord], 
                              previousDeletedRecordsIds: [CKRecord.ID],
                              completion: @escaping ((_ changedRecords: [CKRecord], _ deletedRecordsIds: [CKRecord.ID]) -> Void)) {
        
        guard let customZone = self.customZone, let privateDB = self.privateDB else {
            RCLog("Not logged in")
            return
        }
        
        var changedRecords = previousRecords
        var deletedRecordsIds = previousDeletedRecordsIds
        
        let options = CKFetchRecordZoneChangesOperation.ZoneOptions()
        options.previousServerChangeToken = token
        
        //        let op = CKFetchRecordZoneChangesOperation(recordZoneIDs: [customZone.zoneID], previousServerChangeToken: token)
        let op = CKFetchRecordZoneChangesOperation(recordZoneIDs: [customZone.zoneID], optionsByRecordZoneID: [customZone.zoneID: options])
        op.fetchAllChanges = true
//        let op = CKFetchDatabaseChangesOperation(previousServerChangeToken: token)
        
        op.recordChangedBlock = { record in
            RCLog("Changed record: \(record)")
            changedRecords.append(record)
        }
        op.recordZoneChangeTokensUpdatedBlock = { zoneId, serverChangeToken, data in
            
        }
        op.recordZoneFetchCompletionBlock = { zoneId, serverChangeToken, data, moreComing, error in
            RCLogO(serverChangeToken)
            RCLogO(data)
            RCLogErrorO(error)
            
            guard error == nil else {
                if let ckerror = error as? CKError {
                    switch ckerror {
                    case CKError.changeTokenExpired:
                        // Reset the token and try to do the request again
                        UserDefaults.standard.serverChangeToken = nil
                        self.fetchChangedRecords(token: nil,
                                                 previousRecords: changedRecords,
                                                 previousDeletedRecordsIds: deletedRecordsIds,
                                                 completion: completion)
                        return
                    default:
                        break
                    }
                }
                completion(changedRecords, deletedRecordsIds)
                return
            }
            UserDefaults.standard.serverChangeToken = serverChangeToken
            
            if moreComing {
                self.fetchChangedRecords(token: serverChangeToken,
                                         previousRecords: changedRecords,
                                         previousDeletedRecordsIds: deletedRecordsIds,
                                         completion: completion)
            } else {
                completion(changedRecords, deletedRecordsIds)
            }
        }
        op.fetchRecordZoneChangesCompletionBlock = { error in
            
        }
        op.recordWithIDWasDeletedBlock = { recordID, recordType in
            RCLog("Deleted recordID: \(recordID)")
            deletedRecordsIds.append(recordID)
        }
//        op.fetchRecordChangesCompletionBlock = { serverChangeToken, data, error in
//            
//            
//        }
        
        privateDB.add(op)
    }
    
    func fetchRecords (ofType type: String, predicate: NSPredicate, completion: @escaping ((_ record: [CKRecord]?) -> Void)) {
        
        guard let customZone = self.customZone, let privateDB = self.privateDB else {
            RCLog("Not logged in")
            return
        }
        
        let query = CKQuery(recordType: type, predicate: predicate)
        privateDB.perform(query, inZoneWith: customZone.zoneID) { (results: [CKRecord]?, error) in
            
            RCLogErrorO(error)
            
            if let results = results {
                completion(results)
            } else {
                completion(nil)
            }
        }
    }
}
