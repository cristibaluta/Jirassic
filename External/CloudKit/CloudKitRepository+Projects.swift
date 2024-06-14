//
//  CloudKitRepository+Projects.swift
//  Jirassic
//
//  Created by Cristian Baluta on 12/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit
import RCLog

extension CloudKitRepository: RepositoryProjects {

    func projects() -> [Project] {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryProjects(_ completion: @escaping (_ projects: [Project]) -> Void) {
        let predicate = NSPredicate(value: true)
        projectsZone?.fetchRecords(ofType: "Project", predicate: predicate) { records in
            completion( self.projectsFromRecords(records ?? []) )
        }
    }
    
    func queryUpdates (_ completion: @escaping ([Project], [String], NSError?) -> Void) {
        
        let changeToken = ReadMetadataInteractor().projectsLastSyncToken()
        
        projectsZone?.fetchChangedRecords(token: changeToken,
                                          previousRecords: [],
                                          previousDeletedRecordsIds: [],
                                          completion: { changedRecords, deletedRecordsIds in
                            
            completion(self.projectsFromRecords(changedRecords), self.stringIdsFromCKRecordIds(deletedRecordsIds), nil)
        })
    }
    
    func saveProject (_ project: Project, completion: @escaping ((_ task: Project?) -> Void)) {
        RCLogO("1. Save to cloudkit \(project)")
        
        guard let zoneId = self.tasksZone?.zoneId, let privateDB = self.privateDB else {
            RCLog("Can't save, not logged in to iCloud")
            return
        }
        
        // Query for the task from server if exists
        fetchCKRecordOfProject(project) { record in
            var record: CKRecord? = record
            // No record found on server, creating one now
            if record == nil {
                let recordId = CKRecord.ID(recordName: project.objectId!, zoneID: zoneId)
                record = CKRecord(recordType: "Project", recordID: recordId)
            }
            record!.update(with: project)
            
            privateDB.save(record!, completionHandler: { savedRecord, error in
                
                RCLog("2. Record after saving to CloudKit")
                RCLogO(savedRecord)
                RCLogErrorO(error)
                
                if let record = savedRecord {
                    let project = record.toProject()
                    completion(project)
                }
                if let ckerror = error as? CKError {
                    switch ckerror {
                    case CKError.quotaExceeded:
                        // The user has run out of iCloud storage space.
                        // Prompt the user to go to iCloud Settings to manage storage.
                        #warning("Present quotaExceeded message to the user")
                        break
                    default:
                        break
                    }
                    completion(nil)
                }
            })
        }
    }
    
    func deleteProject (_ project: Project, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
        guard let privateDB = self.privateDB else {
            RCLog("Not logged in")
            return
        }
        
        fetchCKRecordOfProject(project) { record in
            if let cproject = record {
                
                privateDB.delete(withRecordID: cproject.recordID, completionHandler: { recordID, error in
                    RCLogO(recordID)
                    RCLogErrorO(error)
                    completion(error != nil)
                })
            } else {
                completion(false)
            }
        }
    }
}

extension CloudKitRepository {
    
    func fetchCKRecordOfProject (_ project: Project, completion: @escaping ((_ cproject: CKRecord?) -> Void)) {
        
        guard let zoneId = self.tasksZone?.zoneId, let privateDB = self.privateDB else {
            RCLog("Not logged in")
            return
        }
        
        let predicate = NSPredicate(format: "objectId == %@", project.objectId! as CVarArg)
        let query = CKQuery(recordType: "Project", predicate: predicate)
        privateDB.perform(query, inZoneWith: zoneId) { (results: [CKRecord]?, error) in
            
            RCLogErrorO(error)
            
            if let result = results?.first {
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    private func projectsFromRecords (_ records: [CKRecord]) -> [Project] {
        return records.map({ $0.toProject() })
    }
}
