//
//  WelcomeViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 10/12/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

class WelcomeViewController: NSViewController {
    
    weak var appWireframe: AppWireframe?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayer()
    }
    
    @IBAction func handleStartButton (_ sender: NSButton) {
        localPreferences.set(false, forKey: .firstLaunch, version: Versioning.appVersion)
        appWireframe!.flipToTasksController()
    }
    
    @IBAction func handleSettingsButton (_ sender: NSButton) {
        localPreferences.set(false, forKey: .firstLaunch, version: Versioning.appVersion)
        appWireframe!.flipToSettingsController()
    }
}

extension WelcomeViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}
