//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

enum SettingsTab: Int {
    case tracking = 0
    case input = 1
    case output = 2
}

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
        
        trackingScrollView.save()
        inputsScrollView.save()
        outputsScrollView.save()
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
    
    func setShellStatus (compatible: Bool, scriptInstalled: Bool) {
        inputsScrollView.setShellStatus (compatible: compatible, scriptInstalled: scriptInstalled)
    }
    
    func setJirassicStatus (compatible: Bool, scriptInstalled: Bool) {
        inputsScrollView.setJirassicStatus (compatible: compatible, scriptInstalled: scriptInstalled)
    }
    
    func setJitStatus (compatible: Bool, scriptInstalled: Bool) {
        inputsScrollView.setJitStatus (compatible: compatible, scriptInstalled: scriptInstalled)
    }
    
    func setGitStatus (commandInstalled: Bool, scriptInstalled: Bool) {
        inputsScrollView.setGitStatus (commandInstalled: commandInstalled, scriptInstalled: scriptInstalled)
    }
    
    func setBrowserStatus (compatible: Bool, scriptInstalled: Bool) {
        inputsScrollView.setBrowserStatus (compatible: compatible, scriptInstalled: scriptInstalled)
    }
    
    func setHookupStatus (commandInstalled: Bool, scriptInstalled: Bool) {
        outputsScrollView.setHookupStatus (commandInstalled: commandInstalled, scriptInstalled: scriptInstalled)
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
    
    func selectTab (_ tab: SettingsTab) {
        tabView.selectTabViewItem(at: tab.rawValue)
        if tab == .output {
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
