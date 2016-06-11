//
//  PopoverViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 24/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
	
    var appWireframe: AppWireframe?
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
        appWireframe = AppDelegate.sharedApp().appWireframe
        appWireframe?.viewController = self
        
        let currentUser = UserInteractor(data: localRepository).currentUser()
		if currentUser.isLoggedIn {
            appWireframe?.presentTasksController()
		} else {
            appWireframe?.presentLoginController()
		}
    }
}
