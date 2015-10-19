//
//  SettingsViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
	
	var handleSaveButton: (() -> ())?
	var handleCloseButton: (() -> ())?
	
	@IBOutlet private var emailTextField: NSTextField?
	@IBOutlet private var passwordTextField: NSTextField?
	@IBOutlet private var butLogin: NSButton?
	@IBOutlet private var progressIndicator: NSProgressIndicator?
	
	var credentials: LoginCredentials {
		get {
			return (email: self.emailTextField!.stringValue,
				password: self.passwordTextField!.stringValue)
		}
		set {
			self.emailTextField!.stringValue = newValue.email
			self.passwordTextField!.stringValue = newValue.password
		}
	}
	
	class func instanceFromStoryboard() -> SettingsViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateControllerWithIdentifier("SettingsViewController") as! SettingsViewController
		return vc
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		if let user = JRUser.currentUser() {
			RCLogO(user.isLoggedIn)
			butLogin?.title = user.isLoggedIn ? "Logout" : "Login"
			emailTextField?.stringValue = user.email!
		}
    }
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	func showLoadingIndicator(show: Bool) {
		if show {
			progressIndicator?.startAnimation(nil)
		} else {
			progressIndicator?.stopAnimation(nil)
		}
	}
	
	
	// MARK: Actions
	
	@IBAction func handleLoginButton(sender: NSButton) {
		
		let login = Login(credentials: self.credentials)
		login.onLoginSuccess = {
			self.showLoadingIndicator(false)
		}
		if let user = JRUser.currentUser() {
			user.isLoggedIn ? login.logout() : login.login()
		}
	}
	
	@IBAction func handleSaveButton(sender: NSButton) {
		self.handleSaveButton!()
	}
	
}
