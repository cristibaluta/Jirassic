//
//  PopoverViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 24/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class PopoverViewController: NSViewController {
	
	private var _tasksController: TasksViewController?
	private var _settingsController: SettingsViewController?
	private var _loginController: LoginViewController?
	
    override func viewDidLoad() {
		
		super.viewDidLoad()
		
		var currentUser = PFUser.currentUser()
		
		if currentUser != nil {
			let controller = createTasksController()
			self.view.addSubview( controller.view )
		}
		else {
			let controller = createLoginController()
			self.view.addSubview( controller.view )
		}
    }
	
	func createTasksController() -> TasksViewController {
		
		if _tasksController == nil {
			_tasksController = TasksViewController.instanceFromStoryboard()
			_tasksController?.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
			_tasksController?.handleSettingsButton = {[weak self] () in
				if let strongSelf = self {
					strongSelf.flipToSettings()
				}
			}
		}
		
		return _tasksController!
	}
	
	func removeTasksController() {
		if _tasksController != nil {
			_tasksController!.removeFromSuperview()
		}
	}
	
	
	// MARK: Settings
	
	func createSettingsController() -> SettingsViewController {
		
		if _settingsController == nil {
			_settingsController = SettingsViewController.instanceFromStoryboard()
			_settingsController?.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
			_settingsController?.handleSaveButton = {[weak self] () in
				if let strongSelf = self {
					strongSelf.flipToTasks()
				}
			}
		}
		
		return _settingsController!
	}
	
	func removeSettingsController() {
		if _settingsController != nil {
			_settingsController!.removeFromSuperview()
		}
	}
	
	func createLoginController() -> LoginViewController {
		
		if _loginController == nil {
			_loginController = LoginViewController.instanceFromStoryboard()
			_loginController?.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
			_loginController?.onLoginSuccess = {[weak self] () in
				if let strongSelf = self {
					strongSelf.flipToTasks()
				}
			}
			_loginController?.handleCancelLoginButton = {[weak self] () in
				if let strongSelf = self {
					strongSelf.flipToTasks()
				}
			}
		}
		
		return _loginController!
	}
	
	func removeLoginController() {
		if _loginController != nil {
			_loginController!.removeFromSuperview()
			_loginController = nil
		}
	}
	
	
	// MARK: Flip popup views
	
	func flipToSettings() {
		
		let flip = FlipScreens()
		flip.animationReachedMiddle = {
			self.removeTasksController()
			self.view.addSubview( self.createSettingsController().view )
		}
		flip.animationFinished = {
			
		}
		flip.startWithLayer(self.view.superview!.layer!)
	}
	
	func flipToLogin() {
		
		let flip = FlipScreens()
		flip.animationReachedMiddle = {
			self.removeTasksController()
			self.view.addSubview( self.createLoginController().view )
		}
		flip.animationFinished = {
			
		}
		flip.startWithLayer(self.view.superview!.layer!)
	}
	
	func flipToTasks() {
		
		let flip = FlipScreens()
		flip.animationReachedMiddle = {
			self.removeSettingsController()
			self.removeLoginController()
			self.view.addSubview( self.createTasksController().view )
		}
		flip.animationFinished = {
			
		}
		flip.startWithLayer( self.view.superview!.layer! )
	}
}
