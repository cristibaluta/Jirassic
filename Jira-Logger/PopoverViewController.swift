//
//  PopoverViewController.swift
//  Jira-Logger
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
		RCLogO(currentUser)
		
		if currentUser != nil {
			let controller = tasksController()
			self.view.addSubview( controller.view )
		}
		else {
			let controller = loginController()
			self.view.addSubview( controller.view )
		}
    }
	
	func tasksController() -> TasksViewController {
		
		if _tasksController == nil {
			_tasksController = TasksViewController.instanceFromStoryboard()
			_tasksController?.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
			_tasksController?.onButSettingsPressed = {[weak self] () in
				if let strongSelf = self {
					strongSelf.flipToLogin()
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
	
	func settingsController() -> SettingsViewController {
		
		if _settingsController == nil {
			_settingsController = SettingsViewController.instanceFromStoryboard()
			_settingsController?.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
			_settingsController?.onButSavePressed = {[weak self] () in
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
	
	func loginController() -> LoginViewController {
		
		if _loginController == nil {
			_loginController = LoginViewController.instanceFromStoryboard()
			_loginController?.view.frame = CGRect(x: 0, y: 0,
				width: self.view.frame.size.width, height: self.view.frame.size.height)
			_loginController?.onLoginSuccess = {[weak self] () in
				if let strongSelf = self {
					strongSelf.flipToTasks()
				}
			}
			_loginController?.onLoginCancel = {[weak self] () in
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
		
		let flip = Flip()
		flip.animationReachedMiddle = {
			self.removeTasksController()
			self.view.addSubview( self.settingsController().view )
		}
		flip.animationFinished = {
			
		}
		flip.startWithLayer(self.view.superview!.layer!)
	}
	
	func flipToLogin() {
		
		let flip = Flip()
		flip.animationReachedMiddle = {
			self.removeTasksController()
			self.view.addSubview( self.loginController().view )
		}
		flip.animationFinished = {
			
		}
		flip.startWithLayer(self.view.superview!.layer!)
	}
	
	func flipToTasks() {
		
		let flip = Flip()
		flip.animationReachedMiddle = {
			self.removeSettingsController()
			self.removeLoginController()
			self.view.addSubview( self.tasksController().view )
		}
		flip.animationFinished = {
			
		}
		flip.startWithLayer( self.view.superview!.layer! )
	}
}
