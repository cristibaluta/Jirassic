//
//  InternalSettings.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Foundation

class InternalSettings {
    
    fileprivate let userDefaults = UserDefaults.standard
    
    fileprivate let launchAtStartupKey = "InternalSettings.launchAtStartup"
    var launchAtStartup: Bool {
        get {
            guard userDefaults.object(forKey: launchAtStartupKey) != nil else {
                return false
            }
            return userDefaults.bool(forKey: launchAtStartupKey)
        }
        set {
            userDefaults.set(newValue, forKey: launchAtStartupKey)
            userDefaults.synchronize()
        }
    }
    
    
    func setRoundDay (_ on: Bool) {
        userDefaults.set(on, forKey: "InternalSettings.RoundDay")
        userDefaults.synchronize()
    }
    
    func roundDay() -> Bool {
        
        guard userDefaults.object(forKey: "InternalSettings.RoundDay") != nil else {
            return true
        }
        return userDefaults.bool(forKey: "InternalSettings.RoundDay")
    }
    
    func setUsePercents (_ on: Bool) {
        userDefaults.set(on, forKey: "InternalSettings.UsePercents")
        userDefaults.synchronize()
    }
    
    func usePercents() -> Bool {
        
        guard userDefaults.object(forKey: "InternalSettings.UsePercents") != nil else {
            return true
        }
        return userDefaults.bool(forKey: "InternalSettings.UsePercents")
    }
}
