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
	
	@IBOutlet private var emailTextField: NSTextField?
	@IBOutlet private var passwordTextField: NSTextField?
    @IBOutlet private var butLogin: NSButton?
	@IBOutlet private var progressIndicator: NSProgressIndicator?
    // Jit
    @IBOutlet private var jitImageView: NSImageView?
    @IBOutlet private var jitTextField: NSTextField?
    @IBOutlet private var butInstallJit: NSButton?
    
    weak var appWireframe: AppWireframe?
    var settingsPresenter: SettingsPresenterInput?
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
		
        let container = CKContainer.defaultContainer()
        container.requestApplicationPermission(.UserDiscoverability) { (status, error) in
            guard error == nil else { return }
            
            if status == CKApplicationPermissionStatus.Granted {
                container.fetchUserRecordIDWithCompletionHandler { (recordID, error) in
                    guard error == nil else { return }
                    guard let recordID = recordID else { return }
                    
                    container.discoverUserInfoWithUserRecordID(recordID) { (info, fetchError) in
                        // use info.firstName and info.lastName however you need
                        print(info)
                    }
                }
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        settingsPresenter!.testJit()
        
//		let user = UserInteractor().currentUser()
//        butLogin?.title = user.isLoggedIn ? "Logout" : "Login"
//        emailTextField?.stringValue = user.email!
    }
	
	
	// MARK: Actions
    
    @IBAction func handleInstallJitButton (sender: NSButton) {
        if settingsPresenter!.jitInstalled {
            settingsPresenter!.uninstallJit()
        } else {
            settingsPresenter!.installJit()
        }
    }
    
	@IBAction func handleLoginButton (sender: NSButton) {
        settingsPresenter!.login(credentials)
	}
	
	@IBAction func handleSaveButton (sender: NSButton) {
		appWireframe!.flipToTasksController()
	}
}

extension SettingsViewController: SettingsPresenterOutput {
    
    func showLoadingIndicator (show: Bool) {
        if show {
            progressIndicator!.startAnimation(nil)
        } else {
            progressIndicator!.stopAnimation(nil)
        }
    }
    
    func setJitIsInstalled (installed: Bool) {
        
        jitImageView?.image = NSImage(named: installed ? NSImageNameStatusAvailable : NSImageNameStatusUnavailable)
        jitTextField?.stringValue = installed ? "Jit command line tool is installed" : "Jit command line tool is not installed yet"
        butInstallJit!.title = installed ? "Uninstall" : "Install"
    }
}
