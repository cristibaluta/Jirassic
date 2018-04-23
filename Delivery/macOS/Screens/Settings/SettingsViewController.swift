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
    
    @IBOutlet fileprivate var segmentedControl: NSSegmentedControl!
    @IBOutlet fileprivate var container: NSBox!
    @IBOutlet fileprivate var butBackup: NSButton!
    @IBOutlet fileprivate var butEnableLaunchAtStartup: NSButton!
    // Tracking tab
    fileprivate var trackingView: TrackingView?
    // Input tab
    fileprivate var inputsScrollView: InputsScrollView?
    // Output tab
    fileprivate var outputsScrollView: OutputsScrollView?
    
    weak var appWireframe: AppWireframe?
    var presenter: SettingsPresenterInput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
	
    override func viewDidAppear() {
        super.viewDidAppear()
        createLayer()
        
        trackingView = TrackingView.instantiateFromXib()
        inputsScrollView = InputsScrollView.instantiateFromXib()
        outputsScrollView = OutputsScrollView.instantiateFromXib()
        
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
            settingsTracking: trackingView!.settings(),
            settingsBrowser: inputsScrollView!.settings()
        )
        presenter!.saveAppSettings(settings)
        
        trackingView?.save()
        inputsScrollView?.save()
        outputsScrollView?.save()
    }
    
    deinit {
        RCLog("deinit")
    }
    
    func removeSelectedTabView() {
        trackingView!.removeFromSuperview()
        inputsScrollView!.removeFromSuperview()
        outputsScrollView!.removeFromSuperview()
    }
}

extension SettingsViewController {
	
    @IBAction func handleSaveButton (_ sender: NSButton) {
        appWireframe!.flipToTasksController()
    }
    
    @IBAction func handleBackupButton (_ sender: NSButton) {
        presenter!.enableBackup(sender.state == NSControl.StateValue.on)
    }
    
    @IBAction func handleLaunchAtStartupButton (_ sender: NSButton) {
        presenter!.enableLaunchAtStartup(sender.state == NSControl.StateValue.on)
    }
    
    @IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        let tab = SettingsTab(rawValue: sender.selectedSegment)!
        presenter!.selectTab(tab)
    }
    
    @IBAction func handleQuitAppButton (_ sender: NSButton) {
        NSApplication.shared.terminate(nil)
    }
    
    @IBAction func handleMinimizeAppButton (_ sender: NSButton) {
        AppDelegate.sharedApp().menu.triggerClose()
    }
}

extension SettingsViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

extension SettingsViewController: SettingsPresenterOutput {
    
    func setShellStatus (available: Bool, compatible: Bool) {
        inputsScrollView?.setShellStatus (available: available, compatible: compatible)
    }
    
    func setJirassicStatus (available: Bool, compatible: Bool) {
        inputsScrollView?.setJirassicStatus (available: available, compatible: compatible)
    }
    
    func setJitStatus (available: Bool, compatible: Bool) {
        inputsScrollView?.setJitStatus (available: available, compatible: compatible)
    }
    
    func setGitStatus (available: Bool) {
        inputsScrollView?.setGitStatus (available: available)
    }
    
    func setBrowserStatus (available: Bool, compatible: Bool) {
        inputsScrollView?.setBrowserStatus (available: available, compatible: compatible)
    }
    
    func setHookupStatus (available: Bool) {
        outputsScrollView?.setHookupStatus (available: available)
    }
    
    func showAppSettings (_ settings: Settings) {
        
        trackingView?.showSettings(settings.settingsTracking)
        inputsScrollView?.showSettings(settings.settingsBrowser)
        
        butBackup.state = settings.enableBackup ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    func enableLaunchAtStartup (_ enabled: Bool) {
        butEnableLaunchAtStartup.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
    }
    
    func enableBackup (_ enabled: Bool, title: String) {
        butBackup.state = enabled ? NSControl.StateValue.on : NSControl.StateValue.off
        butBackup.title = title
    }
    
    func selectTab (_ tab: SettingsTab) {
        removeSelectedTabView()
        segmentedControl!.selectedSegment = tab.rawValue
        switch tab {
        case .tracking:
            container.addSubview(trackingView!)
            trackingView!.constrainToSuperview()
        case .input:
            container.addSubview(inputsScrollView!)
            inputsScrollView!.constrainToSuperview()
        case .output:
            container.addSubview(outputsScrollView!)
            outputsScrollView!.constrainToSuperview()
        }
    }
}
