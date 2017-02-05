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
            guard let oldValue = get(launchAtStartupKey) else {
                return false
            }
            return oldValue as! Bool
        }
        set {
            set(newValue, forKey: launchAtStartupKey)
        }
    }
    
    
    fileprivate let roundDayKey = "InternalSettings.RoundDay"
    var roundDay: Bool {
        get {
            guard let oldValue = get(roundDayKey) else {
                return true
            }
            return oldValue as! Bool
        }
        set {
            set(newValue, forKey: roundDayKey)
        }
    }
    
    
    fileprivate let usePercentsKey = "InternalSettings.UsePercents"
    var usePercents: Bool {
        get {
            guard let oldValue = get(usePercentsKey) else {
                return true
            }
            return oldValue as! Bool
        }
        set {
            set(newValue, forKey: usePercentsKey)
        }
    }
    
    
    func setFirstLaunch (_ on: Bool, forVersion version: String) {
        set(on, forKey: "InternalSettings.FirstLaunch-" + version)
    }
    
    func isFirstLaunch (forVersion version: String) -> Bool {
        
        guard let oldValue = get("InternalSettings.FirstLaunch-" + version) else {
            return true
        }
        return oldValue as! Bool
    }
}

extension InternalSettings {
    
    fileprivate func get (_ key: String) -> Any? {
        return userDefaults.object(forKey: key)
    }
    
    fileprivate func set (_ value: Any, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
}
