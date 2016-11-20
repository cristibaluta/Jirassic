//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import CloudKit

class SettingsViewController: NSViewController {
	
	@IBOutlet fileprivate var emailTextField: NSTextField?
	@IBOutlet fileprivate var passwordTextField: NSTextField?
    @IBOutlet fileprivate var butLogin: NSButton?
	@IBOutlet fileprivate var progressIndicator: NSProgressIndicator?
    // Jit
    @IBOutlet fileprivate var jitImageView: NSImageView?
    @IBOutlet fileprivate var jitTextField: NSTextField?
    @IBOutlet fileprivate var butInstallJit: NSButton?
    // Jira
    @IBOutlet fileprivate var jiraUrlTextField: NSTextField?
    @IBOutlet fileprivate var jiraUserTextField: NSTextField?
    @IBOutlet fileprivate var jiraPasswordTextField: NSTextField?
    // Settings
    @IBOutlet fileprivate var butAutoTrackLunch: NSButton!
    @IBOutlet fileprivate var butAutoTrackScrum: NSButton!
    @IBOutlet fileprivate var butShowSuggestions: NSButton!
    @IBOutlet fileprivate var lunchTimePicker: NSDatePicker!
    @IBOutlet fileprivate var scrumMeetingTimePicker: NSDatePicker!
    @IBOutlet fileprivate var startDayTimePicker: NSDatePicker!
    
    weak var appWireframe: AppWireframe?
    var presenter: SettingsPresenterInput?
	var credentials: UserCredentials {
		get {
			return (email: self.emailTextField!.stringValue,
				password: self.passwordTextField!.stringValue)
		}
		set {
			self.emailTextField!.stringValue = newValue.email
			self.passwordTextField!.stringValue = newValue.password
		}
	}
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
//        let container = CKContainer.default()
//        container.requestApplicationPermission(.userDiscoverability) { (status, error) in
//            guard error == nil else { return }
//            
//            if status == CKApplicationPermissionStatus.granted {
//                container.fetchUserRecordID { (recordID, error) in
//                    guard error == nil else { return }
//                    guard let recordID = recordID else { return }
//                    
//                    container.discoverUserInfo(withUserRecordID: recordID) { (info, fetchError) in
//                        // use info.firstName and info.lastName however you need
//                        print(info)
//                    }
//                }
//            }
//        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        presenter!.loadJitInfo()
        presenter!.showSettings()
        
//		let user = UserInteractor().currentUser()
//        butLogin?.title = user.isLoggedIn ? "Logout" : "Login"
//        emailTextField?.stringValue = user.email!
    }
	
	
	// MARK: Actions
    
    @IBAction func handleInstallJitButton (_ sender: NSButton) {
        if sender.title == "Install" {
            presenter!.installJit()
        } else {
            presenter!.uninstallJit()
        }
    }
    
	@IBAction func handleLoginButton (_ sender: NSButton) {
        presenter!.login(credentials)
	}
	
	@IBAction func handleSaveButton (_ sender: NSButton) {
		
        let settings = Settings(autoTrackLunch: butAutoTrackLunch.state == NSOnState,
                                autoTrackScrum: butAutoTrackScrum.state == NSOnState,
                                showSuggestions: butShowSuggestions.state == NSOnState,
                                lunchTime: lunchTimePicker.dateValue,
                                scrumMeetingTime: scrumMeetingTimePicker.dateValue,
                                startDayTime: startDayTimePicker.dateValue
        )
        presenter!.saveAppSettings(settings)
        
        appWireframe!.flipToTasksController()
	}
}

extension SettingsViewController: SettingsPresenterOutput {
    
    func showLoadingIndicator (_ show: Bool) {
        if show {
            progressIndicator!.startAnimation(nil)
        } else {
            progressIndicator!.stopAnimation(nil)
        }
    }
    
    func setJitIsInstalled (_ installed: Bool) {
        
        jitImageView?.image = NSImage(named: installed ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)
        jitTextField?.stringValue = installed ? "Shell support is installed" : "Shell support not installed yet"
        butInstallJit!.title = installed ? "Uninstall" : "Install"
    }
    
    func setJiraSettings (_ settings: JiraSettings) {
        
        jiraUrlTextField!.stringValue = settings.url ?? ""
        jiraUserTextField!.stringValue = settings.user ?? ""
//        jiraPasswordTextField!.stringValue = nil
    }
    
    func showAppSettings (_ settings: Settings) {
        
        butAutoTrackLunch.state = settings.autoTrackLunch == true ? NSOnState : NSOffState
        butAutoTrackScrum.state = settings.autoTrackScrum == true ? NSOnState : NSOffState
        butShowSuggestions.state = settings.showSuggestions == true ? NSOnState : NSOffState
        lunchTimePicker.dateValue = settings.lunchTime!
        scrumMeetingTimePicker.dateValue = settings.scrumMeetingTime!
        startDayTimePicker.dateValue = settings.startDayTime!
    }
}
