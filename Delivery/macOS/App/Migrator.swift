//
//  Migrator.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit

class Migrator {
    
    static func migrate() {
        
        if let lastSyncDateWithRemote = UserDefaults.standard.object(forKey: "localChangeDate") as? Date {
            WriteMetadataInteractor().set(tasksLastSyncDate: lastSyncDateWithRemote)
            UserDefaults.standard.removeObject(forKey: "localChangeDate")
        }
        
        if let data = UserDefaults.standard.value(forKey: "ChangeToken") as? Data,
            let token = NSKeyedUnarchiver.unarchiveObject(with: data) as? CKServerChangeToken {
            
            WriteMetadataInteractor().set(tasksLastSyncToken: token)
            UserDefaults.standard.removeObject(forKey: "ChangeToken")
        }

        if let _ = UserDefaults.standard.object(forKey: "RCPreferences-settingsGitPaths") as? String {
            UserDefaults.standard.removeObject(forKey: "RCPreferences-settingsGitPaths")
        }
        if let _ = UserDefaults.standard.object(forKey: "RCPreferences-settingsGitAuthors") as? String {
            UserDefaults.standard.removeObject(forKey: "RCPreferences-settingsGitAuthors")
        }
    }
}
