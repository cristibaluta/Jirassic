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
    
    internal var user: User?
    internal let privateDB = CKContainer.default().privateCloudDatabase
    internal let customZone = CKRecordZone(zoneName: "TasksZone")
    internal let preferences = RCPreferences<LocalPreferences>()
    
    init() {
        CKContainer.default().accountStatus(completionHandler: { (status, error) in
            RCLog(status.rawValue)
            RCLogErrorO(error)
        })
        privateDB.save(customZone) { (recordZone, err) in
            RCLogO(recordZone)
            RCLogErrorO(err)
        }
    }
}

extension CloudKitRepository {
    
    func fetchChangedRecords (token: CKServerChangeToken?, 
                              previousRecords: [CKRecord], 
                              previousDeletedRecordsIds: [CKRecordID], 
                              completion: @escaping ((_ changedRecords: [CKRecord], _ deletedRecordsIds: [CKRecordID]) -> Void)) {
        
        var records = previousRecords
        var deletedRecordsIds = previousDeletedRecordsIds
        
//        CKFetchRecordZoneChangesOperation
        let op = CKFetchRecordChangesOperation(recordZoneID: customZone.zoneID, previousServerChangeToken: nil)
        
        op.recordChangedBlock = { record in
            RCLog(record)
            records.append(record)
        }
        op.recordWithIDWasDeletedBlock = { recordID in
            RCLog(recordID)
            deletedRecordsIds.append(recordID)
        }
        op.fetchRecordChangesCompletionBlock = { serverChangeToken, data, error in
            
            RCLogO(serverChangeToken)
            RCLogO(data)
            RCLogErrorO(error)
            guard error == nil else {
                
                return
            }
            UserDefaults.standard.serverChangeToken = serverChangeToken
            
            if op.moreComing {
                self.fetchChangedRecords(token: serverChangeToken, 
                                         previousRecords: records, 
                                         previousDeletedRecordsIds: deletedRecordsIds, 
                                         completion: completion)
            } else {
                completion(records, deletedRecordsIds)
            }
        }
        privateDB.add(op)
    }
    
    func fetchRecords (ofType type: String, predicate: NSPredicate, completion: @escaping ((_ ctask: [CKRecord]?) -> Void)) {
        
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

public extension UserDefaults {
    
    var serverChangeToken: CKServerChangeToken? {
        get {
            guard let data = self.value(forKey: "ChangeToken") as? Data else {
                return nil
            }
            guard let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken else {
                return nil
            }
            
            return token
        }
        set {
            if let token = newValue {
                let data = NSKeyedArchiver.archivedData(withRootObject: token)
                self.set(data, forKey: "ChangeToken")
                self.synchronize()
            } else {
                self.removeObject(forKey: "ChangeToken")
            }
        }
    }
}
