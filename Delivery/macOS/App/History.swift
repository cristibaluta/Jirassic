//
//  History.swift
//  Jirassic
//
//  Created by Cristian Baluta on 11/12/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation

class History {
    
    func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "launched")
    }
    
    func setLaunched() {
        UserDefaults.standard.set(true, forKey: "launched")
    }
}
