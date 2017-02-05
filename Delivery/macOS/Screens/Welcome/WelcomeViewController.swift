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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayer()
    }
    
    @IBAction func handleStartButton (_ sender: NSButton) {
        InternalSettings().setFirstLaunch(true, forVersion: appVersion)
        appWireframe!.flipToTasksController()
    }
    
    @IBAction func handleSettingsButton (_ sender: NSButton) {
        InternalSettings().setFirstLaunch(true, forVersion: appVersion)
        appWireframe!.flipToSettingsController()
    }
}

extension WelcomeViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}
