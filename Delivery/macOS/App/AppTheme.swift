//
//  AppTheme.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/05/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

class AppTheme {
    
    var isDark: Bool = false
    var onChange: (() -> ())?
    
    init() {
        isDark = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        DistributedNotificationCenter.default.addObserver(self, 
                                                          selector: #selector(interfaceModeChanged(sender:)), 
                                                          name: NSNotification.Name(rawValue: "AppleInterfaceThemeChangedNotification"), 
                                                          object: nil)
        
    }

    @objc func interfaceModeChanged (sender: NSNotification) {
        isDark = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        onChange?()
    }
}
