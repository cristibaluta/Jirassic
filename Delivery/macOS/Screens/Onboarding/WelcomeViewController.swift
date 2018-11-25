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
        // When app is an update from previous version
        let isFirstLaunchOfThisVersion = pref.string(.appVersion) != Versioning.appVersion
        // Deprecated userdefault, keep it for few versions, needed to present what's new screen
        let wizardStep = UserDefaults.standard.integer(forKey: "RCPreferences-wizardStep")
        let isAnUpdateFromAnotherVersion = pref.string(.appVersion) != "" || wizardStep > 0
        if isFirstLaunchOfThisVersion && isAnUpdateFromAnotherVersion {
            boxWhatsNew.isHidden = false
            boxSetupProgrammers.isHidden = true
            boxSetupOthers.isHidden = true
            whatsNewTextField.stringValue = "• Import meetings from Calendar.app\n• Create monthly reports\n• Fixes bug in editing tasks. Git commits and calendar meetings are not editable, they can only be deleted after the day is closed\n• Extended calendar history to one year\n• Various UI improvements and fixes"
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
        pref.set(Versioning.appVersion, forKey: .appVersion)
        let stepsToSave: [Int] = []
        pref.set(stepsToSave, forKey: .wizardSteps)
        appWireframe!.flipToWizardController()
    }
    
    @IBAction func handleSetupOthersButton (_ sender: NSButton) {
        pref.set(Versioning.appVersion, forKey: .appVersion)
        let stepsSeen = [WizardStep.shell, WizardStep.browser, WizardStep.git]
        let stepsToSave: [Int] = stepsSeen.map({ $0.rawValue })
        pref.set(stepsToSave, forKey: .wizardSteps)
        appWireframe!.flipToWizardController()
    }
    
    @IBAction func handleWhatsNewButton (_ sender: NSButton) {
        pref.set(Versioning.appVersion, forKey: .appVersion)
        let stepsSeen = [WizardStep.shell, WizardStep.browser, WizardStep.git, WizardStep.jira]
        let stepsToSave: [Int] = stepsSeen.map({ $0.rawValue })
        pref.set(stepsToSave, forKey: .wizardSteps)
        // Remove deprecated userdefault
        UserDefaults.standard.removeObject(forKey: "RCPreferences-wizardStep")
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
