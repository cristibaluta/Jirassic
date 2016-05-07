//
//  AppWireframe.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class AppWireframe {

    var viewController: NSViewController?
    
    private var currentController: NSViewController?
    private var _loginViewController: LoginViewController?
    private var _tasksViewController: TasksViewController?
    private var _messageViewController: MessageViewController?
    private var _newTaskViewController: NewTaskViewController?
    private var _settingsViewController: SettingsViewController?
    
    var loginViewController: LoginViewController {
        
        guard _loginViewController == nil else {
            return _loginViewController!
        }
        
        let loginController = LoginViewController.instantiateFromStoryboard("Main")
        loginController.view.frame = CGRect(origin: CGPointZero, size: self.viewController!.view.frame.size)
        
        let loginPresenter = LoginPresenter()
        loginPresenter.userInterface = loginController
        loginController.loginPresenter = loginPresenter
        
        _loginViewController = loginController
        
        return loginController
    }
    
    var messageViewController: MessageViewController {
        
        guard _messageViewController == nil else {
            return _messageViewController!
        }
        
        _messageViewController = MessageViewController.instantiateFromStoryboard("Main")
//            _messageViewController?.didPressButton = { [weak self] () -> Void in
//                self?.handleStartDayButton()
//            }
        
        return _messageViewController!
    }
    
    var newTaskViewController: NewTaskViewController {
        
        guard _newTaskViewController == nil else {
            return _newTaskViewController!
        }
        
        _newTaskViewController = NewTaskViewController.instantiateFromStoryboard("Main")
        _newTaskViewController?.onOptionChosen = { [weak self] (i: TaskSubtype) -> Void in
            
//                self?.splitView?.hidden = false
//                
//                var task = Task(subtype: i)
//                task.notes = self!._newTaskViewController!.notes
//                task.issueType = self!._newTaskViewController!.issueType
//                task.issueId = self!._newTaskViewController!.issueId
//                if task.endDate != nil {
//                    task.endDate = self!._newTaskViewController!.date
//                } else if task.startDate != nil {
//                    task.startDate = self!._newTaskViewController!.date
//                }
//                
//                SaveTaskInteractor(data: localRepository).saveTask(task)
//                self?.tasksScrollView?.addTask( task )
//                
//                self?.setupDaysTableView()
//                self?.tasksScrollView?.tableView?.insertRowsAtIndexes(
//                    NSIndexSet(index: 0), withAnimation: NSTableViewAnimationOptions.SlideUp)
//                self?.tasksScrollView?.tableView?.scrollRowToVisible(0)
//                
//                self?.updateNoTasksState()
//                self?.removeNewTaskController()
        }
        _newTaskViewController?.onCancelChosen = {
//            self.splitView?.hidden = false
            self.removeNewTaskController()
        }
        
        return _newTaskViewController!
    }
    
    var tasksViewController: TasksViewController {
        
        guard _tasksViewController == nil else {
            return _tasksViewController!
        }
        
        let tasksController = TasksViewController.instantiateFromStoryboard("Main")
        let tasksPresenter = TasksPresenter()
        
        tasksController.appWireframe = self
        tasksController.tasksPresenter = tasksPresenter
        tasksController.view.frame = CGRect(origin: CGPointZero, size: self.viewController!.view.frame.size)
        
        tasksPresenter.userInterface = tasksController
        tasksPresenter.appWireframe = self
        
        _tasksViewController = tasksController
        
        return tasksController
    }
    
    var settingsViewController: SettingsViewController {
        
        guard _settingsViewController == nil else {
            return _settingsViewController!
        }
        
        let settingsController = SettingsViewController.instantiateFromStoryboard("Main")
        let settingsPresenter = SettingsPresenter()
        
        settingsPresenter.userInterface = settingsController
        settingsController.view.frame = CGRect(origin: CGPointZero, size: self.viewController!.view.frame.size)
        settingsController.settingsPresenter = settingsPresenter
        _settingsViewController = settingsController
        
        return settingsController
    }
    
    
    func removeMessagesController() {
        if let controller = _messageViewController {
            removeController(controller)
        }
    }
    
    func removeNewTaskController() {
        if let controller = _newTaskViewController {
            removeController(controller)
        }
    }
    
//    func flipToTasks (fromController: NSViewController) {
//        
//        flipToTasks(
//            self.createTasksController(),
//            parentController: self,
//            currentController: fromController,
//            completion: { [weak self] controller in
//                if let strongSelf = self {
//                    strongSelf.topController = controller
//                }
//            }
//        )
//    }
}

extension AppWireframe {
	
	func showPopover (popover: NSPopover, fromIcon icon: NSView) {
		let edge = NSRectEdge.MinY
		let rect = icon.frame
		popover.showRelativeToRect(rect, ofView: icon, preferredEdge: edge);
	}
	
	func hidePopover (popover: NSPopover) {
		popover.close()
	}
	
	func removeController (controller: NSViewController) {
		controller.removeFromParentViewController()
		controller.view.removeFromSuperview()
	}
	
	func presentNewTaskController (controller: NSViewController,
		overController parentController: NSViewController,
		splitView: NSSplitView) {
		
		parentController.addChildViewController(controller)
        parentController.view.addSubview(controller.view)
        controller.view.constrainToSuperviewWidth()
        controller.view.constrainToSuperviewHeight(70, bottom: 0)
	}
	
	func removeNoProjectsController (controller: NSViewController?) {
		
		if let c = controller {
			c.view.removeFromSuperview()
			c.removeFromParentViewController()
		}
	}
}

extension AppWireframe {
    
    func presentLoginController() {
        
        currentController = self.loginViewController
        self.viewController?.addChildViewController( currentController! )
        self.viewController?.view.addSubview( currentController!.view )
        
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
//            self.removeTasksController()
            self.viewController!.view.addSubview( self.currentController!.view )
        }
        flip.animationFinished = {
            
        }
        flip.startWithLayer(self.viewController!.view.superview!.layer!)
    }
}

extension AppWireframe {
    
    func presentTasksController() {
        
        let tasksController = self.tasksViewController
        self.viewController?.addChildViewController( tasksController )
        self.viewController?.view.addSubview( tasksController.view )
        
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
            // Remove current controller
//            self.removeController(self.currentController!)
            // Add new controller
            self.viewController?.addChildViewController(tasksController)
            self.viewController?.view.addSubview(tasksController.view)
        }
        flip.animationFinished = {
//            completion(controller: tasksController)
        }
        flip.startWithLayer(tasksController.view.layer!)
    }
}

extension AppWireframe {
    
    func presentMessage (message: MessageViewModel, intoSplitView splitView: NSSplitView) {
        
        let messageController = self.messageViewController
//        messageViewController.viewModel = message
        
        self.viewController!.addChildViewController(self.viewController!)
        splitView.subviews[1].addSubview(self.viewController!.view)
        messageController.view.constrainToSuperview()
    }
}

extension AppWireframe {
    
    func presentSettingsController() {
        
        let settingsController = self.settingsViewController
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
            // Remove current controller
            self.removeController(self.currentController!)
            // Add new controller
            self.viewController?.addChildViewController(settingsController)
            self.viewController?.view.addSubview(settingsController.view)
        }
        flip.animationFinished = {
//            completion(controller: settingsController)
        }
        flip.startWithLayer(self.viewController!.view.superview!.layer!)
        
//        flipToSettings(
//            ,
//            parentController: strongSelf,
//            currentController: strongSelf.topController!,
//            completion: {(controller) -> Void in
//                strongSelf.topController = controller
//            }
//        )
    }
}
