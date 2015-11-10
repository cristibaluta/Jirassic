//
//  TasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksViewController: NSViewController {
	
	@IBOutlet private var splitView: NSSplitView?
	@IBOutlet private var daysScrollView: DaysScrollView?
	@IBOutlet private var tasksScrollView: TasksScrollView?
	
	@IBOutlet private var _dateLabel: NSTextField?
	@IBOutlet private var _butRefresh: NSButton?
	@IBOutlet private var _progressIndicator: NSProgressIndicator?
	
	private var _noTasksViewController: NoTasksViewController?
	private var _newTaskViewController: NewTaskViewController?
	private var _newDayController = NewDay()
	
	var handleSettingsButton: (() -> ())?
	var handleRefreshButton: (() -> ())?
	var handleDrawerButton: (() -> ())?
	var handleQuitAppButton: (() -> ())?
	var selectedDate: NSDate?
	
	
	class func instanceFromStoryboard() -> TasksViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		return storyboard.instantiateControllerWithIdentifier("TasksViewController") as! TasksViewController
	}
	
	override func awakeFromNib() {
		view.layer = CALayer()
		view.wantsLayer = true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		updateNoTasksState()
		reloadDataFromServer()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		if _newDayController.isNewDay() {
			reloadData()
		}
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: Selector("newTaskWasAdded:"), name: "newTaskWasAdded", object: nil)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	func setupDaysTableView() {
		
		daysScrollView!.data = sharedData.days()
		daysScrollView?.didSelectRow = { (row: Int) in
			if row >= 0 {
				let theData = self.daysScrollView!.data[row]
				if let dateEnd = theData.date_task_finished {
					self.reloadTasksOnDay( dateEnd )
				} else if let dateStart = theData.date_task_started {
					self.reloadTasksOnDay( dateStart )
				}
			}
		}
		daysScrollView?.reloadData()
	}
	
	func setupTasksTableView() {
		
		tasksScrollView!.didRemoveRow = { (row: Int) in
			RCLogO("remove \(row)")
			if row >= 0 {
                let theData = self.tasksScrollView!.data[row]
                self.tasksScrollView!.removeTaskAtRow(row);
                sharedData.deleteTask(theData)
			}
		}
		tasksScrollView!.didAddRow = { [weak self] (row: Int) -> Void in
			let theData = self?.tasksScrollView!.data[row]
            if let date = theData?.date_task_finished {
                self?.handleAddTaskButton(date)
            }
		}
	}
	
	func updateNoTasksState() {
		RCLogO("updateNoTasksState")
		if tasksScrollView!.data.count == 0 {
			let controller = noTasksController()
			controller.showStartState()
			Wireframe.presentNoTaskController(controller, overController: self, splitView: splitView!)
		}
		else if tasksScrollView!.data.count == 1 {
			let controller = noTasksController()
			controller.showFirstTaskState()
		}
		else {
			removeNoTasksController()
		}
	}
	
	func noTasksController() -> NoTasksViewController {
		
		if _noTasksViewController == nil {
			_noTasksViewController = NoTasksViewController.instanceFromStoryboard()
			_noTasksViewController?.handleStartButton = { [weak self] () -> Void in
				self?.handleStartDayButton()
			}
		}
		
		return _noTasksViewController!
	}
	
	func removeNoTasksController() {
		if let controller = _noTasksViewController {
			Wireframe.removeNoTaskController(controller, fromController: self)
		}
	}
	
	func newTaskController() -> NewTaskViewController {
		
		if _newTaskViewController == nil {
			_newTaskViewController = NewTaskViewController.instanceFromStoryboard()
			_newTaskViewController?.onOptionChosen = { [weak self] (i: TaskSubtype) -> Void in
				
				self?.splitView?.hidden = false
				
				let task: TaskProtocol = Tasks.taskFromSubtype(i)
				task.saveToServerWhenPossible()
				self?.tasksScrollView?.addTask( task )
				
				self?.setupDaysTableView()
				self?.tasksScrollView?.tableView?.insertRowsAtIndexes(NSIndexSet(index: 0),
					withAnimation: NSTableViewAnimationOptions.SlideUp)
				self?.tasksScrollView?.tableView?.scrollRowToVisible( 0 )
				
				self?.updateNoTasksState()
				self?.removeNewTaskController()
			}
		}
		
		return _newTaskViewController!
	}
	
	func removeNewTaskController() {
		if _newTaskViewController != nil {
			newTaskController().removeFromSuperview()
		}
	}
	
	func showLoadingIndicator(show: Bool) {
		if show {
			_progressIndicator?.startAnimation(nil)
		} else {
			_progressIndicator?.stopAnimation(nil)
		}
		self._butRefresh?.hidden = show
	}
	
	func reloadDataFromServer() {
		self.showLoadingIndicator(true)
		sharedData.queryData { [weak self] (tasks, error) -> Void in
			RCLog(tasks)
			self?.reloadData()
			self?.showLoadingIndicator(false)
		}
	}
	
	func reloadData() {
		self.setupDaysTableView()
		self.setupTasksTableView()
		self.reloadTasksOnDay(NSDate())
	}
	
	func reloadTasksOnDay(date: NSDate) {
		
		tasksScrollView!.data = sharedData.tasksForDayOfDate(date)
		tasksScrollView?.reloadData()
		tasksScrollView?.hidden = false
		
		self._dateLabel?.stringValue = date.EEEEMMdd()
		
		updateNoTasksState()
	}
	
	func newTaskWasAdded(notif: NSNotification) {
		if let task = notif.object as? Task {
			self.tasksScrollView?.addTask( task )
			self.tasksScrollView?.tableView?.insertRowsAtIndexes(NSIndexSet(index: 0),
				withAnimation: NSTableViewAnimationOptions.SlideUp)
			self.tasksScrollView?.tableView?.scrollRowToVisible( 0 )
			self.updateNoTasksState()
		}
	}
	
	
	// MARK: Actions
	
	func handleStartDayButton() {
		
		let task = Tasks.taskFromDate(NSDate(), dateEnd: NSDate(), type: TaskType.Start)
		task.saveToServerWhenPossible()
		
		self._newDayController.setLastTrackedDay(NSDate())
		self.reloadData()
	}
	
	func handleAddTaskButton(date: NSDate) {
		RCLogO("add new cell after date \(date)")
		removeNoTasksController()
		splitView?.hidden = true
		let controller = newTaskController()
		view.addSubview( controller.view )
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		handleSettingsButton?()
	}
	
	@IBAction func handleRefreshButton(sender: NSButton) {
		reloadDataFromServer()
	}
}
