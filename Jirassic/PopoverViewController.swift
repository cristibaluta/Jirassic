//
//  PopoverViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 24/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import CloudKit

class PopoverViewController: NSViewController {
	
    var appWireframe: AppWireframe?
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
        appWireframe = AppDelegate.sharedApp().appWireframe
        appWireframe?.viewController = self
        
        if let _ = remoteRepository {
            CKContainer.default().accountStatus(completionHandler: { [weak self] (accountStatus, error) in
                if accountStatus == .noAccount {
                    self?.appWireframe?.presentLoginController()
                } else {
                    self?.appWireframe?.presentTasksController()
                }
            })
        } else {
            appWireframe?.presentTasksController()
        }
//        let currentUser = UserInteractor(data: localRepository).currentUser()
//		if currentUser.isLoggedIn {
//            appWireframe?.presentTasksController()
//		} else {
//            appWireframe?.presentLoginController()
//		}
    }
}
