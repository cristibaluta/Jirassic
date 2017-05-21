//
//  LoginViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 25/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
	
	@IBOutlet private var butLogin: UIButton!
	@IBOutlet private var infoTextField: UILabel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Jirassic"
        handleLoginButton(butLogin)
    }
    
    @IBAction func handleLoginButton (_ sender: UIButton) {
        
        remoteRepository?.getUser({ (user) in
            if user != nil {
                self.performSegue(withIdentifier: "ShowDaysSegue", sender: nil)
            }
        })
    }
}
