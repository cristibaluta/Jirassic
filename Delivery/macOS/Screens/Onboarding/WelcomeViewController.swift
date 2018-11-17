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
    @IBOutlet var boxSetupProgrammers: NSBox!
    @IBOutlet var boxSetupOthers: NSBox!
    @IBOutlet var boxWhatsNew: NSBox!
    @IBOutlet var whatsNewTextField: NSTextField!
    private let pref = RCPreferences<LocalPreferences>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayer()
       // if AppTheme().isDark {
         //   box.fillColor = NSColor.clear
       // }
        
        // Do we need to display  what's new box?
        if true {
            boxWhatsNew.isHidden = false
            boxSetupProgrammers.isHidden = true
            boxSetupOthers.isHidden = true
            whatsNewTextField.stringValue = "-- Include Calendar.app events in the reports\n-- Create monthly reports\n-- Fixes tasks not being editable. Git commits and calendar events are not editable but they can be deleted after the day is closed\n-- Various UI improvements and fixes"
        } else {
            boxWhatsNew.isHidden = true
            boxSetupProgrammers.isHidden = false
            boxSetupOthers.isHidden = false
        }
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
    
    @IBAction func handleWhatsNewButton (_ sender: NSButton) {
        pref.set(false, forKey: .firstLaunch, version: Versioning.appVersion)
        let stepsSeen = [WizardStep.shell, WizardStep.browser, WizardStep.git, WizardStep.jira]
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
