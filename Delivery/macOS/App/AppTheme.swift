//
//  AppTheme.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa

class AppTheme {
    
    var isDark: Bool {
        get {
            return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        }
    }
    var onChange: (() -> ())?
    var highlightColor: NSColor {
        get {
            return isDark
                    ? NSColor(red: 200/255.0, green: 120/255.0, blue: 100/255.0, alpha: 1.0)
                    : NSColor(red: 200/255.0, green: 120/255.0, blue: 180/255.0, alpha: 1.0)
        }
    }
    
    init() {
        DistributedNotificationCenter.default.addObserver(self, 
                                                          selector: #selector(interfaceModeChanged(sender:)), 
                                                          name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), 
                                                          object: nil)
        
    }

    @objc func interfaceModeChanged (sender: NSNotification) {
        onChange?()
    }
}
