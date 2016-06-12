//
//  LoginViewController.swift
//  Jirassic
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
	
    var loginPresenter: LoginPresenterInput?
    
	var credentials: UserCredentials {
		get {
			return (email: self._emailTextField!.stringValue,
				password: self._passwordTextField!.stringValue)
		}
		set {
			self._emailTextField!.stringValue = newValue.email
			self._passwordTextField!.stringValue = newValue.password
		}
	}
	var isLoggedIn: Bool = false
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        if let repository = remoteRepository {
            let user = UserInteractor(data: repository).currentUser()
            if user.isLoggedIn {
                _butLogin?.title = "Logout"
                _label?.stringValue = "You are already logged in."
                self.credentials = (email: user.email!, password: "")
            } else {
                _butLogin?.title = "Login or Signup"
                _label?.stringValue = "You are currently using the app in annonymous mode. By logging in you ensure you never lose the data and you can sync with the phone. Preferably to register with your work e-mail"
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func handleLoginButton (sender: NSButton) {
        loginPresenter?.loginWithCredentials(credentials)
    }
    
    @IBAction func handleCancelButton (sender: NSButton) {
        loginPresenter?.cancelScreen()
    }
}

extension LoginViewController: LoginPresenterOutput {

    func showLoadingIndicator (show: Bool) {
		if show {
			_progressIndicator?.startAnimation(nil)
		} else {
			_progressIndicator?.stopAnimation(nil)
		}
	}
}
