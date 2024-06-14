//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import RCPreferences
import RCLog

enum SettingsTab: Int {
    case tracking = 0
    case input = 1
    case output = 2
    case store = 3
}

class SettingsViewController: NSViewController {
    
    @IBOutlet private var segmentedControl: NSSegmentedControl!
    @IBOutlet private var container: NSBox!
    @IBOutlet private var butBackup: NSButton!
    @IBOutlet private var butEnableLaunchAtStartup: NSButton!
    // Tracking tab
    private var trackingView: TrackingView?
    // Input tab
    private var inputsScrollView: InputsScrollView?
    // Output tab
    private var outputsScrollView: OutputsScrollView?
    // Store tab
    private var storeView: StoreView?
    
    weak var appWireframe: AppWireframe?
    var presenter: SettingsPresenterInput?
    private let localPreferences = RCPreferences<LocalPreferences>()
	
    override func viewDidAppear() {
        super.viewDidAppear()
        createLayer()
        
        trackingView = TrackingView.instantiateFromXib()
        inputsScrollView = InputsScrollView.instantiateFromXib()
        outputsScrollView = OutputsScrollView.instantiateFromXib()
//        storeView = StoreView.instantiateFromXib()
        
        presenter!.checkExtensions()
        presenter!.showSettings()

        inputsScrollView?.onPurchasePressed = { [weak self] in
            self?.presenter?.selectTab(.store)
        }
        outputsScrollView?.onPurchasePressed = { [weak self] in
            self?.presenter?.selectTab(.store)
        }
        
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
//        storeView!.removeFromSuperview()
    }
}

extension SettingsViewController {
	
    @IBAction func handleSaveButton (_ sender: NSButton) {
        appWireframe!.flipToMainController()
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
    
    func setShellStatus (compatibility: Compatibility) {
        inputsScrollView?.setShellStatus (compatibility: compatibility)
    }
    
    func setJirassicStatus (compatibility: Compatibility) {
        inputsScrollView?.setJirassicStatus (compatibility: compatibility)
    }
    
    func setJitStatus (compatibility: Compatibility) {
        inputsScrollView?.setJitStatus (compatibility: compatibility)
    }
    
    func setGitStatus (available: Bool) {
        inputsScrollView?.setGitStatus (available: available)
    }
    
    func setBrowserStatus (compatibility: Compatibility) {
        inputsScrollView?.setBrowserStatus (compatibility: compatibility)
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
        case .store:
            break
//            container.addSubview(storeView!)
//            storeView!.constrainToSuperview()
        }
    }
}
