//
//  PopoverViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 24/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
	
	private var topController: NSViewController?
	
    override func viewDidLoad() {
		super.viewDidLoad()
		
		let currentUser = ReadUserInteractor().execute()
		if currentUser.isLoggedIn {
			topController = createTasksController()
			self.addChildViewController( topController! )
			self.view.addSubview( topController!.view )
		} else {
			// You cannot use the app without an account
			topController = createLoginController()
			self.addChildViewController( topController! )
			self.view.addSubview( topController!.view )
		}
    }
	
	func createTasksController() -> TasksViewController {
		
		let tasksController = TasksViewController.instantiateFromStoryboard("Main")
		tasksController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
		tasksController.handleSettingsButton = { [weak self] in
			if let strongSelf = self {
				Wireframe.flipToSettings(
					strongSelf.createSettingsController(),
					parentController: strongSelf,
					currentController: strongSelf.topController!,
					completion: {(controller) -> Void in
						strongSelf.topController = controller
					}
				)
			}
		}
		
		return tasksController
	}
	
	func createSettingsController() -> SettingsViewController {
		
		let settingsController = SettingsViewController.instantiateFromStoryboard("Main")
		settingsController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
		settingsController.handleSaveButton = { [weak self] in
			self?.flipToTasks(settingsController)
		}
		
		return settingsController
	}
	
	func createLoginController() -> LoginViewController {
        
        let loginController = LoginViewController.instantiateFromStoryboard("Main")
        loginController.view.frame = CGRect(origin: CGPointZero, size: self.view.frame.size)
        
        let loginPresenter = LoginPresenter()
        loginPresenter.onLoginSuccess = { [weak self] in
            self?.flipToTasks(loginController)
        }
        loginPresenter.onExit = { [weak self] in
            self?.flipToTasks(loginController)
        }
        loginPresenter.userInterface = loginController
        loginController.loginPresenter = loginPresenter
        
		return loginController
	}
	
	func flipToTasks (fromController: NSViewController) {
		
		Wireframe.flipToTasks(
			self.createTasksController(),
			parentController: self,
			currentController: fromController,
			completion: { [weak self] controller in
				if let strongSelf = self {
					strongSelf.topController = controller
				}
			}
		)
	}
}
