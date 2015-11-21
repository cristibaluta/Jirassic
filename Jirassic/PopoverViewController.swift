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
		
		let currentUser = PUser.currentUser()
		if currentUser != nil && currentUser!.isLoggedIn {
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
		
		let tasksController = TasksViewController.instanceFromStoryboard()
		tasksController.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
		tasksController.handleSettingsButton = {[weak self] () in
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
		
		let settingsController = SettingsViewController.instanceFromStoryboard()
		settingsController.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
		settingsController.handleSaveButton = {[weak self] () in
			self?.flipToTasks(settingsController)
		}
		
		return settingsController
	}
	
	func createLoginController() -> LoginViewController {
		
		let loginController = LoginViewController.instanceFromStoryboard()
		loginController.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
		loginController.onLoginSuccess = {[weak self] () in
			self?.flipToTasks(loginController)
		}
		loginController.handleCancelLoginButton = {[weak self] () in
			self?.flipToTasks(loginController)
		}
		
		return loginController
	}
	
	func flipToTasks(fromController: NSViewController) {
		Wireframe.flipToTasks(
			self.createTasksController(),
			parentController: self,
			currentController: fromController,
			completion: {[weak self](controller) -> Void in
				if let strongSelf = self {
					strongSelf.topController = controller
				}
			}
		)
	}
}
