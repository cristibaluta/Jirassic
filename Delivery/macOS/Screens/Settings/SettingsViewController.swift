//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    
    @IBOutlet fileprivate var tabView: NSTabView!
    @IBOutlet fileprivate var butBackup: NSButton!
    @IBOutlet fileprivate var butEnableLaunchAtStartup: NSButton!
    // Tracking tab
    @IBOutlet fileprivate var trackingScrollView: TrackingScrollView!
    // Input tab
    @IBOutlet fileprivate var inputsScrollView: InputsScrollView!
    // Output tab
    @IBOutlet fileprivate var outputsScrollView: OutputsScrollView!
    
    weak var appWireframe: AppWireframe?
    var presenter: SettingsPresenterInput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
	
    override func viewDidAppear() {
        super.viewDidAppear()
        createLayer()
        
        presenter!.checkExtensions()
        presenter!.showSettings()
        
        #if !APPSTORE
            butBackup.isEnabled = false
            butBackup.state = NSControl.StateValue.off
            butEnableLaunchAtStartup.isEnabled = false
            butEnableLaunchAtStartup.state = NSControl.StateValue.off
        #endif
    }
    
    override func viewWillDisappear() {
        super.viewWillDisappear()
        
        let settings = Settings(
            enableBackup: butBackup.state == NSControl.StateValue.on,
            settingsTracking: trackingScrollView.settings(),
            settingsBrowser: inputsScrollView.settings()
        )
        presenter!.saveAppSettings(settings)
    }
    
    deinit {
        RCLog("deinit")
    }
}

extension SettingsViewController {
	
    @IBAction func handleSaveButton (_ sender: NSButton) {
        appWireframe!.flipToTasksController()
    }
    
    @IBAction func handleBackupButton (_ sender: NSButton) {
        presenter!.enabledBackup(sender.state == NSControl.StateValue.on)
    }
    
    @IBAction func handleLaunchAtStartupButton (_ sender: NSButton) {
        presenter!.enabledLaunchAtStartup(sender.state == NSControl.StateValue.on)
    }
    
}

extension SettingsViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

extension SettingsViewController: SettingsPresenterOutput {
    
    func setJirassicStatus (compatible: Bool, scriptInstalled: Bool) {
        
//        if scriptInstalled {
//            jirassicImageView.image = NSImage(named: compatible ? NSImage.Name.statusAvailable : NSImage.Name.statusPartiallyAvailable)
//            jirassicTextField.stringValue = compatible ? "Run 'jirassic' in Terminal for more info" : "Applescript installed but jirassic cmd is outdated/uninstalled"
//        } else {
//            jirassicImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
//            jirassicTextField.stringValue = "Not installed yet"
//        }
//        butInstallJirassic.isHidden = scriptInstalled && compatible
    }
    
    func setJitStatus (compatible: Bool, scriptInstalled: Bool) {
        
//        if scriptInstalled {
//            jitImageView.image = NSImage(named: compatible ? NSImage.Name.statusAvailable : NSImage.Name.statusPartiallyAvailable)
//            jitTextField.stringValue = compatible ? "Commits made with Jit will log time to Jirassic. Run 'jit' in Terminal for more info" : "Applescript installed but jit cmd is outdated/uninstalled"
//        } else {
//            jitImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
//            jitTextField.stringValue = "Not installed yet"
//        }
//        butInstallJit.isHidden = scriptInstalled && compatible
    }
    
    func setCodeReviewStatus (compatible: Bool, scriptInstalled: Bool) {
        
//        if scriptInstalled {
//            coderevImageView.image = NSImage(named: compatible ? NSImage.Name.statusAvailable : NSImage.Name.statusUnavailable)
//            coderevTextField.stringValue = compatible ? "Jirassic can read the url of your browser and it will log time based on it" : "Applescript installed but outdated"
//        } else {
//            coderevImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
//            coderevTextField.stringValue = "Not installed yet"
//        }
//        butInstallCoderev.isHidden = scriptInstalled && compatible
    }
    
    func showAppSettings (_ settings: Settings) {
        
        trackingScrollView.showSettings(settings.settingsTracking)
        inputsScrollView.showSettings(settings.settingsBrowser)
        
        butBackup.state = settings.enableBackup ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    func enabledLaunchAtStartup (_ enabled: Bool) {
        butEnableLaunchAtStartup.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    func enabledBackup (_ enabled: Bool, title: String) {
        butBackup.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
        butBackup.title = title
    }
    
    func selectTab (atIndex index: Int) {
        tabView.selectTabViewItem(at: index)
        if index == 2 {
//            presenter?.loadJiraProjects()
        }
    }
}

extension SettingsViewController: NSTabViewDelegate {
    
    func tabView(_ tabView: NSTabView, didSelect tabViewItem: NSTabViewItem?) {
        if let item = tabViewItem {
            localPreferences.set( tabView.indexOfTabViewItem(item), forKey: .settingsActiveTab)
        }
    }
}
