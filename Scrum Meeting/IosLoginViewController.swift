//
//  LoginViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 25/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class IosLoginViewController: UIViewController {
	
	@IBOutlet private var _activityIndicator: UIActivityIndicatorView?
	@IBOutlet private var _butLogin: UIButton?
	@IBOutlet private var _emailTextField: UITextField?
	@IBOutlet private var _passwordTextField: UITextField?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		if PFUser.currentUser() == nil {
			
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	@IBAction func handleLogin(sender: UIButton) {
		
		_activityIndicator?.startAnimating()
		
		PFUser.logInWithUsernameInBackground(_emailTextField!.text, password:_passwordTextField!.text) {
			(user: PFUser?, error: NSError?) -> Void in
			if user != nil {
				self._activityIndicator?.stopAnimating()
				self.performSegueWithIdentifier("ShowDaysSegue", sender: nil)
			} else if let error = error {
				let errorString = error.userInfo?["error"] as? NSString
				RCLogO(errorString)
			}
		}
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
