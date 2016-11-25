//
//  AccountViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

class AccountViewController: NSViewController {
    
    @IBOutlet fileprivate var emailTextField: NSTextField?
    @IBOutlet fileprivate var passwordTextField: NSTextField?
    @IBOutlet fileprivate var butLogin: NSButton?
    @IBOutlet fileprivate var progressIndicator: NSProgressIndicator?
    
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
        //		let user = UserInteractor().currentUser()
        //        butLogin?.title = user.isLoggedIn ? "Logout" : "Login"
        //        emailTextField?.stringValue = user.email!
    }
    
    @IBAction func handleLoginButton (_ sender: NSButton) {
//        presenter!.login(credentials)
    }
    
    func login (_ credentials: UserCredentials) {
        
        //        let interactor = UserInteractor(data: localRepository)
        //        interactor.onLoginSuccess = {
        //            self.userInterface?.showLoadingIndicator(false)
        //        }
        //        let user = interactor.currentUser()
        //        user.isLoggedIn ? interactor.logout() : interactor.loginWithCredentials(credentials)
    }
    
    func showLoadingIndicator (_ show: Bool) {
        if show {
            progressIndicator!.startAnimation(nil)
        } else {
            progressIndicator!.stopAnimation(nil)
        }
    }
    
}
