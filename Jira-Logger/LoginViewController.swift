//
//  LoginViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 07/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
	
	@IBOutlet private var _label: NSTextField?
	@IBOutlet private var _emailTextField: NSTextField?
	@IBOutlet private var _passwordTextField: NSTextField?
	@IBOutlet private var _butLogin: NSButton?
	@IBOutlet private var _butCancel: NSButton?
	@IBOutlet private var _progressIndicator: NSProgressIndicator?
	
	var onLoginSuccess: (() -> ())?
	var onLoginCancel: (() -> ())?
	
	class func instanceFromStoryboard() -> LoginViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard!.instantiateControllerWithIdentifier("LoginViewController") as! LoginViewController
		return vc
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		var currentUser = PFUser.currentUser()
		RCLogO(currentUser)
		if currentUser != nil && currentUser?.username != nil {
			// Do stuff with the user
			_butLogin?.title = "Logout"
			_emailTextField?.stringValue = currentUser!.username!
			_label?.stringValue = "You are already logged in."
		} else {
			// Show the signup or login screen
			_butLogin?.title = "Signup or Login"
			_label?.stringValue = "You are currently using the app in annonymous mode. By logging in you ensure you never lose the data and you can sync with the phone. Preferably to register with your work e-mail"
		}
    }
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	
	// MARK: Actions
	
	@IBAction func handleLoginButton(sender: NSButton) {
		self.login()
	}
	
	@IBAction func handleCancelButton(sender: NSButton) {
		self.onLoginCancel!()
	}
	
	func register() {
		
		var user = PFUser()
		user.username = _emailTextField?.stringValue
		user.password = _passwordTextField?.stringValue
		user.email = _emailTextField?.stringValue
		RCLogO(user)
		
		_progressIndicator?.startAnimation(nil)
		
		user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
			if let error = error {
				let errorString = error.userInfo?["error"] as? NSString
				RCLogO(errorString)
			} else {
				self._progressIndicator?.stopAnimation(nil)
				self.onLoginSuccess!()
			}
		}
	}
	
	func login() {
		RCLogO(nil)
		_progressIndicator?.startAnimation(nil)
		PFUser.logInWithUsernameInBackground(_emailTextField!.stringValue, password:_passwordTextField!.stringValue) {
			(user: PFUser?, error: NSError?) -> Void in
			if user != nil {
				self._progressIndicator?.stopAnimation(nil)
				self.onLoginSuccess!()
			} else if let error = error {
				let errorString = error.userInfo?["error"] as? NSString
				RCLogO(errorString)
				self.register()
			}
		}
	}
}
