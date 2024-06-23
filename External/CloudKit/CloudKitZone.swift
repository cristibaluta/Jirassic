//
//  CloudKitZone.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit
import RCLog

class CloudKitZone {
    
    private var db: CKDatabase
    private var customZone: CKRecordZone?
    
    var zoneId: CKRecordZone.ID? {
        return customZone?.zoneID
    }
    
    init (db: CKDatabase, zoneName: String) {
        
        self.db = db
        self.customZone = CKRecordZone(zoneName: zoneName)
        
        db.save(customZone!) { (recordZone, err) in
            RCLogO(recordZone)
            RCLogErrorO(err)
        }
    }
    
    func fetchChangedRecords (token: CKServerChangeToken?,
                              previousRecords: [CKRecord],
                              previousDeletedRecordsIds: [CKRecord.ID],
                              completion: @escaping ((_ changedRecords: [CKRecord], _ deletedRecordsIds: [CKRecord.ID]) -> Void)) {
        
        guard let zoneId = self.zoneId else {
            RCLog("Not logged in")
            return
        }
        
        var changedRecords = previousRecords
        var deletedRecordsIds = previousDeletedRecordsIds
        
        let options = CKFetchRecordZoneChangesOperation.ZoneOptions()
        options.previousServerChangeToken = token
        
        //        let op = CKFetchRecordZoneChangesOperation(recordZoneIDs: [customZone.zoneID], previousServerChangeToken: token)
        let op = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneId],
                                                   optionsByRecordZoneID: [zoneId: options])
        op.fetchAllChanges = true
//        let op = CKFetchDatabaseChangesOperation(previousServerChangeToken: token)
        
        op.recordChangedBlock = { record in
            RCLog("Changed record: \(record)")
            changedRecords.append(record)
        }
        op.recordZoneChangeTokensUpdatedBlock = { zoneId, serverChangeToken, data in
            /// Do not save the toke here because the results are not yet saved to local db
//            WriteMetadataInteractor().set(tasksLastSyncToken: serverChangeToken)
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
                        WriteMetadataInteractor().set(tasksLastSyncToken: nil)
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
            WriteMetadataInteractor().set(tasksLastSyncToken: serverChangeToken)
            
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
        
        db.add(op)
    }
    
    func fetchRecords (ofType type: String, predicate: NSPredicate, completion: @escaping ((_ record: [CKRecord]?) -> Void)) {
        
        guard let zoneId = self.zoneId else {
            RCLog("Not logged in")
            return
        }
        
        let query = CKQuery(recordType: type, predicate: predicate)
        db.perform(query, inZoneWith: zoneId) { (results: [CKRecord]?, error) in
            
            RCLogErrorO(error)
            
            if let results = results {
                completion(results)
            } else {
                completion(nil)
            }
        }
    }
}
