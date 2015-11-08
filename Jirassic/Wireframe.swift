//
//  Wireframe.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class Wireframe: NSObject {

	class func flipToSettings(settingsController: NSViewController, parentController: NSViewController, currentController: NSViewController, completion: (controller: NSViewController) -> Void) {
		
		let flip = FlipScreens()
		flip.animationReachedMiddle = {
			// Remove current controller
			currentController.view.removeFromSuperview()
			currentController.removeFromParentViewController()
			// Add new controller
			parentController.addChildViewController(settingsController)
			parentController.view.addSubview(settingsController.view)
		}
		flip.animationFinished = {
			completion(controller: settingsController)
		}
		flip.startWithLayer(parentController.view.superview!.layer!)
	}
	
	func flipToLogin() {
		
//		let flip = FlipScreens()
//		flip.animationReachedMiddle = {
//			self.removeTasksController()
//			self.view.addSubview( self.createLoginController().view )
//		}
//		flip.animationFinished = {
//			
//		}
//		flip.startWithLayer(self.view.superview!.layer!)
	}
	
	class func flipToTasks(tasksController: NSViewController, parentController: NSViewController, currentController: NSViewController, completion: (controller: NSViewController) -> Void) {
		
		let flip = FlipScreens()
		flip.animationReachedMiddle = {
			// Remove current controller
			currentController.view.removeFromSuperview()
			currentController.removeFromParentViewController()
			// Add new controller
			parentController.addChildViewController(tasksController)
			parentController.view.addSubview(tasksController.view)
		}
		flip.animationFinished = {
			completion(controller: tasksController)
		}
		flip.startWithLayer(parentController.view.superview!.layer!)
	}
	
	
	class func presentNoTaskController(controller: NSViewController, overController parentController: NSViewController, splitView: NSSplitView) {
		
		parentController.addChildViewController(controller)
		splitView.subviews[1].addSubview(controller.view)
		controller.view.constrainToSuperview()
	}
	
	class func removeNoTaskController(controller: NSViewController, fromController parentController: NSViewController) {
		parentController.addChildViewController(controller)
		controller.view.removeFromSuperview()
	}
	
	class func presentNewTaskController(childController: NSViewController, overController parentController: NSViewController) {
		
		parentController.addChildViewController(childController)
		parentController.view.addSubview(childController.view)
		childController.view.removeAutoresizing()
		childController.view.constrainToSuperviewWidth()
		childController.view.constrainToSuperviewHeight()
	}
	
	class func removeNoProjectsController(controller: NSViewController?) {
		
		if let c = controller {
			c.view.removeFromSuperview()
			c.removeFromParentViewController()
		}
	}
}
