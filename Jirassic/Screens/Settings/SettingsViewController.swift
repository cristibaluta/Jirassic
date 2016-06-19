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
    @IBOutlet private var butQuit: NSButton?
	@IBOutlet private var progressIndicator: NSProgressIndicator?
    
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
        container.fetchUserRecordIDWithCompletionHandler() {
            recordID, error in
            print("fetched ID \(recordID?.recordName)")
            container.discoverUserInfoWithUserRecordID(recordID!, completionHandler: { (userInfo, error) in
                print(userInfo)
            })
        }
        
//		let user = UserInteractor().currentUser()
//        butLogin?.title = user.isLoggedIn ? "Logout" : "Login"
//        emailTextField?.stringValue = user.email!
    }
	
	
	// MARK: Actions
	
	@IBAction func handleLoginButton (sender: NSButton) {
        settingsPresenter?.login(credentials)
	}
	
	@IBAction func handleSaveButton (sender: NSButton) {
		appWireframe?.flipToTasksController()
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
