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
    var textColor: NSColor {
        get {
            return isDark
                    ? NSColor(red: 240/255.0, green: 190/255.0, blue: 80/255.0, alpha: 1.0)
                    : NSColor(red: 200/255.0, green: 120/255.0, blue: 180/255.0, alpha: 1.0)
        }
    }
    var lineColor: NSColor {
        get {
            return isDark
                ? NSColor(calibratedWhite: 1.0, alpha: 0.2)
                : NSColor(calibratedWhite: 0.0, alpha: 0.2)
        }
    }
    var highlightLineColor: NSColor {
        get {
            return isDark
                ? NSColor(calibratedWhite: 1.0, alpha: 1.0)
                : NSColor(calibratedWhite: 0.0, alpha: 1.0)
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
