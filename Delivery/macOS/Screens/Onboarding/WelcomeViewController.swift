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
    @IBOutlet var butSetupProgrammers: NSButton!
    @IBOutlet var butSetupOthers: NSButton!
    private let pref = RCPreferences<LocalPreferences>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayer()
       // if AppTheme().isDark {
         //   box.fillColor = NSColor.clear
       // }
    }
    
    deinit {
        RCLog("deinit")
    }
    
    @IBAction func handleSetupProgrammersButton (_ sender: NSButton) {
        // Set that we saw this version of the app launch
        pref.set(false, forKey: .firstLaunch, version: Versioning.appVersion)
        let stepsToSave: [Int] = []
        pref.set(stepsToSave, forKey: .wizardSteps)
        appWireframe!.flipToWizardController()
    }
    
    @IBAction func handleSetupOthersButton (_ sender: NSButton) {
        pref.set(false, forKey: .firstLaunch, version: Versioning.appVersion)
        let stepsSeen = [WizardStep.shell, WizardStep.browser, WizardStep.git]
        let stepsToSave: [Int] = stepsSeen.map({ $0.rawValue })
        pref.set(stepsToSave, forKey: .wizardSteps)
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
