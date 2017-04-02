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
    internal let customZone = CKRecordZone(zoneName: "TasksZone")
    internal let preferences = RCPreferences<LocalPreferences>()
    
    init() {
        CKContainer.default().accountStatus(completionHandler: { (status, error) in
            RCLog(status.rawValue)
            RCLogErrorO(error)
        })
        privateDB.save(customZone) { (recordZone, err) in
            RCLog(recordZone)
            RCLogErrorO(err)
        }
    }
}

extension CloudKitRepository {
    
    func fetchChangedRecords (token: CKServerChangeToken?) {
//        CKFetchRecordZoneChangesOperation
        let op = CKFetchRecordChangesOperation(recordZoneID: customZone.zoneID, previousServerChangeToken: token)
        
        op.recordChangedBlock = { record in
            RCLog(record)
        }
        
        op.recordWithIDWasDeletedBlock = { recordID in
            RCLog(recordID)
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
                self.fetchChangedRecords(token: serverChangeToken)
            } else {
//                let modifyRecords = CKModifyRecordsOperation(recordsToSave:[recordToSave], recordIDsToDelete: nil)
//                modifyRecords.savePolicy = CKRecordSavePolicy.AllKeys
//                modifyRecords.qualityOfService = NSQualityOfService.UserInitiated
//                modifyRecords.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
//                    if error == nil {
//                        print("Modified")
//                    }else {
//                        print(error)
//                    }
//                }
//                privateDB.addOperation(modifyRecords)
                
            }
        }
        
        privateDB.add(op)
    }
    
    func fetchRecord (ofType type: String, predicate: NSPredicate, completion: @escaping ((_ ctask: CKRecord?) -> Void)) {
        
//        let predicate = NSPredicate(format: "objectId == %@", task.objectId as CVarArg)
        let query = CKQuery(recordType: type, predicate: predicate)
        privateDB.perform(query, inZoneWith: customZone.zoneID) { (results: [CKRecord]?, error) in
            
            RCLogErrorO(error)
            
            if let result = results?.first {
                completion(result)
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
