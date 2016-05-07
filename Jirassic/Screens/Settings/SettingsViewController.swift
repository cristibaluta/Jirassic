//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
	
	@IBOutlet private var emailTextField: NSTextField?
	@IBOutlet private var passwordTextField: NSTextField?
    @IBOutlet private var butLogin: NSButton?
    @IBOutlet private var butQuit: NSButton?
	@IBOutlet private var progressIndicator: NSProgressIndicator?
	
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
    var settingsPresenter: SettingsPresenterInput?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let user = ReadUserInteractor().currentUser()
        butLogin?.title = user.isLoggedIn ? "Logout" : "Login"
        emailTextField?.stringValue = user.email!
    }
	
	
	// MARK: Actions
	
	@IBAction func handleLoginButton (sender: NSButton) {
		
        settingsPresenter?.login(credentials)
	}
	
	@IBAction func handleSaveButton (sender: NSButton) {
		
	}
	
    @IBAction func handleQuitAppButton (sender: NSButton) {
        NSApplication.sharedApplication().terminate(nil)
    }
}

extension SettingsViewController: SettingsPresenterOutput {
    
    func showLoadingIndicator (show: Bool) {
        if show {
            progressIndicator?.startAnimation(nil)
        } else {
            progressIndicator?.stopAnimation(nil)
        }
    }
    
}
