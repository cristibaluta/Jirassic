//
//  LoginViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 07/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {
	
	@IBOutlet private var _emailTextField: NSTextField?
	@IBOutlet private var _passwordTextField: NSTextField?
	@IBOutlet private var _butLogin: NSButton?
	
	var onLoginSuccess: (() -> ())?
	
	class func instanceFromStoryboard() -> LoginViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard!.instantiateControllerWithIdentifier("LoginViewController") as! LoginViewController
		return vc
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	func register() {
		
		var user = PFUser()
		user.username = "myUsername"
		user.password = "myPassword"
		user.email = "email@example.com"
		// other fields can be set just like with PFObject
		user["phone"] = "415-392-0202"
		
		user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
			if let error = error {
				let errorString = error.userInfo?["error"] as? NSString
				// Show the errorString somewhere and let the user try again.
			} else {
				// Hooray! Let them use the app now.
				self.onLoginSuccess!()
			}
		}
	}
}
