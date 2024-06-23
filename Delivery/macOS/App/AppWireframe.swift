//
//  AppWireframe.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class AppWireframe {

    private var _appViewController: AppViewController?
    private var currentController: NSViewController?
    private var _placeholderViewController: PlaceholderViewController?
    private var _worklogsViewController: WorklogsViewController?
    
    var appViewController: AppViewController {
        
        guard _appViewController == nil else {
            return _appViewController!
        }
        _appViewController = AppViewController.instantiateFromStoryboard("Main")
        
        return _appViewController!
    }
    
    private func createWelcomeViewController() -> WelcomeViewController {
        
        let controller = WelcomeViewController.instantiateFromStoryboard("Welcome")
        controller.appWireframe = self
        
        return controller
    }
    
    private func createWizardViewController() -> WizardViewController {
        
        let controller = WizardViewController.instantiateFromStoryboard("Welcome")
        controller.appWireframe = self
        
        return controller
    }
    
    private func createLoginViewController() -> LoginViewController {
        
        let controller = LoginViewController.instantiateFromStoryboard("Login")
        let presenter = LoginPresenter()
        
        controller.loginPresenter = presenter
        presenter.userInterface = controller
        
        return controller
    }
    
    private func createMainViewController() -> MainViewController {
        
        let controller = MainViewController.instantiateFromStoryboard("Main")
        let presenter = MainPresenter()
        
        presenter.ui = controller
        presenter.appWireframe = self
        controller.presenter = presenter
        controller.appWireframe = self
        
        return controller
    }
    
//    private var tasksViewController: TasksViewController {
//
//        let controller = TasksViewController.instantiateFromStoryboard("Tasks")
//        let presenter = TasksPresenter()
//        let interactor = TasksInteractor()
//
//        presenter.ui = controller
//        presenter.interactor = interactor
//        presenter.appWireframe = self
//        interactor.presenter = presenter
//        controller.presenter = presenter
//        controller.appWireframe = self
//
//        return controller
//    }
    
    private func createTaskSuggestionViewController() -> TaskSuggestionViewController {
        
        let controller = TaskSuggestionViewController.instantiateFromStoryboard("Tasks")
        let presenter = TaskSuggestionPresenter()
        
        controller.presenter = presenter
        presenter.userInterface = controller
        
        return controller
    }
    
    private func createSettingsViewController() -> SettingsViewController {
        
        let controller = SettingsViewController.instantiateFromStoryboard("Settings")
        let presenter = SettingsPresenter()
        let interactor = SettingsInteractor()
        
        presenter.userInterface = controller
        presenter.interactor = interactor
        interactor.presenter = presenter
        controller.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 500, height: 500))
        controller.presenter = presenter
        controller.appWireframe = self
        
        return controller
    }
    
    private func createPlaceholderViewController() -> PlaceholderViewController {
        return PlaceholderViewController.instantiateFromStoryboard("Placeholder")
    }
    
    func createWorklogsViewController() -> WorklogsViewController {

        let controller = WorklogsViewController.instantiateFromStoryboard("Worklogs")
        let presenter = WorklogsPresenter()

        controller.presenter = presenter
        controller.appWireframe = self
        presenter.userInterface = controller

        return controller
    }
}

extension AppWireframe {
	
	func showPopover (_ popover: NSPopover, fromIcon icon: NSView) {
		let edge = NSRectEdge.minY
		let rect = icon.frame
		popover.show(relativeTo: rect, of: icon, preferredEdge: edge)
	}
	
	func hidePopover (_ popover: NSPopover) {
		popover.close()
	}
    
    func removeCurrentController() {
        if let c = currentController {
            removeController(c)
            currentController = nil
        }
    }
    
	private func addController (_ controller: NSViewController) {
        appViewController.addChild(controller)
        appViewController.view.addSubview(controller.view)
        controller.view.constrainToSuperview()
	}
    
    private func removeController (_ controller: NSViewController) {
        controller.removeFromParent()
        controller.view.removeFromSuperview()
    }
    
    private func layerToAnimate() -> CALayer {
        return appViewController.view.superview!.layer!
    }
}

extension AppWireframe {
    
    func presentWelcomeController() -> WelcomeViewController {
        
        appViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 560, height: 500))
        let controller = createWelcomeViewController()
        addController(controller)
        currentController = controller
        
        return controller
    }
    
    func presentWizardController() -> WizardViewController {
        
        appViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 560, height: 500))
        let controller = createWizardViewController()
        addController(controller)
        currentController = controller
        
        return controller
    }
    
    func presentLoginController() -> LoginViewController {
        
        let controller = createLoginViewController()
        addController(controller)
        currentController = controller
        
        return controller
    }
    
    func presentMainController() -> MainViewController {
        
        appViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 560, height: 600))
        let controller = createMainViewController()
        addController(controller)
        currentController = controller
        
        return controller
    }
    
    func presentTaskSuggestionController (startSleepDate: Date?, endSleepDate: Date) -> TaskSuggestionViewController {
        
        appViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 450, height: 150))
        let controller = createTaskSuggestionViewController()
        controller.startSleepDate = startSleepDate
        controller.endSleepDate = endSleepDate
        addController(controller)
        currentController = controller
        
        return controller
    }

    // Placeholder
    func presentPlaceholder (_ message: MessageViewModel, in view: NSView) -> PlaceholderViewController {
        
        var controller = _placeholderViewController
        
        if controller == nil {
            controller = createPlaceholderViewController()
            appViewController.addChild(controller!)
            _placeholderViewController = controller
        }
        view.addSubview(controller!.view)
        controller!.view.constrainToSuperview()
        controller!.viewModel = message
        
        return controller!
    }
    
    func removePlaceholder() {
        if let controller = _placeholderViewController {
            removeController(controller)
            _placeholderViewController = nil
        }
    }

    // EndDay
    func presentEndDayController (date: Date, tasks: [Task]) -> WorklogsViewController {

        let controller = createWorklogsViewController()
        controller.date = date
        controller.tasks = tasks
        addController(controller)
        controller.view.constrainToSuperview()
        _worklogsViewController = controller

        return controller
    }

    func removeEndDayController() {
        if let controller = _worklogsViewController {
            removeController(controller)
            _worklogsViewController = nil
        }
    }
}

extension AppWireframe {
    
    func flipToMainController() {
        
        let mainController = createMainViewController()
        let flip = NoAnimation()
        flip.animationReachedMiddle = {
            self.removeCurrentController()
            self.addController(mainController)
            self.currentController = mainController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
    }
    
    func flipToSettingsController() {
        
        let settingsController = createSettingsViewController()
        let window = NSWindow(contentViewController: settingsController)
        window.title = "Jirassic settings"
        window.level = .popUpMenu
        window.makeKeyAndOrderFront(nil)
//        let flip = NoAnimation()
//        flip.animationReachedMiddle = {
//            self.removeCurrentController()
//            self.removePlaceholder()
//            self.removeEndDayController()
//            self.addController(settingsController)
//            self.currentController = settingsController
//        }
//        flip.animationFinished = {}
//        flip.startWithLayer(layerToAnimate())
    }
    
    func flipToLoginController() {
        
        let loginController = createLoginViewController()
        let flip = NoAnimation()
        flip.animationReachedMiddle = {
            self.removeController(self.currentController!)
            self.addController(loginController)
            self.currentController = loginController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
    }
    
    func flipToWizardController() {
        
        let wizardController = createWizardViewController()
        let flip = NoAnimation()
        flip.animationReachedMiddle = {
            self.removeCurrentController()
            self.removePlaceholder()
            self.removeEndDayController()
            self.addController(wizardController)
            self.currentController = wizardController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
    }
}
