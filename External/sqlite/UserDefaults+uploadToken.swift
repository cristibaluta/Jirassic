//
//  UserDefaults+uploadToken.swift
//  Jirassic
//
//  Created by Cristian Baluta on 23/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

public extension UserDefaults {
    
    var lastSyncDateWithRemote: Date? {
        get {
            return self.object(forKey: "localChangeDate") as? Date
        }
        set {
            self.set(newValue, forKey: "localChangeDate")
        }
    }
}
