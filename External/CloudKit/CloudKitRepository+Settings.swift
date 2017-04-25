//
//  CloudKitRepository+Settings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

extension CloudKitRepository: RepositorySettings {
    
    func settings() -> Settings {
        fatalError("Not applicable")
    }
    
    func saveSettings (_ settings: Settings) {
        fatalError("Not applicable")
    }
}
