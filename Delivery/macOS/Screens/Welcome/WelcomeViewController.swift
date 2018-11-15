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
    @IBOutlet var box: NSBox!
    @IBOutlet var butSettings: NSButton!
    @IBOutlet var butStart: NSButton!
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayer()
        if AppTheme().isDark {
            box.fillColor = NSColor.clear
        }
    }
    
    deinit {
        RCLog("deinit")
    }
    
    @IBAction func handleStartButton (_ sender: NSButton) {
        localPreferences.set(false, forKey: .firstLaunch, version: Versioning.appVersion)
        let stepsToSave: [Int] = WizardStep.allCases.map({ $0.rawValue })
        localPreferences.set(stepsToSave, forKey: .wizardSteps)
        appWireframe!.flipToTasksController()
    }
    
    @IBAction func handleSettingsButton (_ sender: NSButton) {
        localPreferences.set(false, forKey: .firstLaunch, version: Versioning.appVersion)
        appWireframe!.flipToWizardController()
    }
    
    @IBAction func handleQuitAppButton (_ sender: NSButton) {
        NSApplication.shared.terminate(nil)
    }
    
    @IBAction func handleMinimizeAppButton (_ sender: NSButton) {
        AppDelegate.sharedApp().menu.triggerClose()
    }
}

extension WelcomeViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}
