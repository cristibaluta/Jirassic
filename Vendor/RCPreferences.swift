//
//  RCPreferences.swift
//
//  Created by Cristian Baluta on 10/03/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

protocol RCPreferencesProtocol {
    var rawValue: String {get}
    func defaultValue() -> Any
}

class RCPreferences<E> where E: RCPreferencesProtocol {
    
    fileprivate let prefix = "RCPreferences-"
    fileprivate let userDefaults = UserDefaults.standard
    
    fileprivate func get (_ key: String) -> Any? {
        return userDefaults.object(forKey: prefix + key)
    }
    
    fileprivate func set (_ value: Any?, forKey key: String) {
        if let v = value {
            userDefaults.set(v, forKey: prefix + key)
        } else {
            userDefaults.removeObject(forKey: prefix + key)
        }
        userDefaults.synchronize()
    }
}

extension RCPreferences {
    
    func bool (_ key: E) -> Bool {
        return get(key) 
    }
    
    /*
     @param version: set the version of this setting
     */
    func bool (_ key: E, version: String) -> Bool {
        return get(key, version: version) 
    }
    
    func int (_ key: E) -> Int {
        return get(key) 
    }
    
    func string (_ key: E) -> String {
        return get(key) 
    }
    
    func date (_ key: E) -> Date {
        return get(key) 
    }
    
    func get<T> (_ key: E, version: String = "") -> T {
        guard let oldValue = get(key.rawValue + version) else {
            return key.defaultValue() as! T
        }
        return oldValue as! T
    }
    
    func set (_ value: Any, forKey key: E, version: String = "") {
        set(value, forKey: key.rawValue + version)
    }
    
    func reset (_ key: E) {
        set(nil, forKey: key.rawValue)
    }
    
    func reset() {
        for (key, _) in list() {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }
    
    func list() -> [String: Any] {
        let allDefaults = userDefaults.dictionaryRepresentation()
        var myDefaults = [String: Any]()
        for (key, value) in allDefaults {
            if key.hasPrefix(prefix) {
                myDefaults[key] = value
            }
        }
        return myDefaults
    }
}
