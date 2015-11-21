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
	private var day = NewDay()
	
	var handleSettingsButton: (() -> ())?
	var handleRefreshButton: (() -> ())?
	var handleDrawerButton: (() -> ())?
	var handleQuitAppButton: (() -> ())?
	var selectedDate: NSDate?
	
    
    // MARK: View controller lifecycle
    
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
		if day.isNewDay() {
			reloadData()
		}
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: Selector("newTaskWasAdded:"), name: "newTaskWasAdded", object: nil)
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
    
    // MARK: Setup
    
	func setupDaysTableView() {
		
		let reader = ReadDaysInteractor(data: sharedData)
		daysScrollView!.data = reader.days()
		daysScrollView?.didSelectRow = { (row: Int) in
			if row >= 0 {
				let theData = self.daysScrollView!.data[row]
				if let dateEnd = theData.endDate {
					self.reloadTasksOnDay( dateEnd )
				} else if let dateStart = theData.startDate {
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
            if let date = theData?.endDate {
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
            Wireframe.presentNoTaskController(controller, overController: self, splitView: splitView!)
		}
		else {
			removeNoTasksController()
		}
	}
	
    
    // MARK: No Tasks
    
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
			Wireframe.removeController(controller)
		}
	}
	
    
    // MARK: New Tasks
    
	func newTaskController() -> NewTaskViewController {
		
		if _newTaskViewController == nil {
			_newTaskViewController = NewTaskViewController.instanceFromStoryboard()
			_newTaskViewController?.onOptionChosen = { [weak self] (i: TaskSubtype) -> Void in
				
				self?.splitView?.hidden = false
				
				let task = Task(subtype: i)
				sharedData.updateTask(task)
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
        if let controller = _newTaskViewController {
            Wireframe.removeController(controller)
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
		sharedData.queryTasks { [weak self] (tasks, error) -> Void in
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
		
		let reader = ReadDayInteractor(data: sharedData)
		tasksScrollView!.data = reader.tasksForDayOfDate(date)
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
		
		let task = Task(dateSart: NSDate(), dateEnd: NSDate(), type: TaskType.Start)
		sharedData.updateTask(task)
		
		day.setLastTrackedDay(NSDate())
		reloadData()
	}
	
	func handleAddTaskButton(date: NSDate) {
		RCLogO("add new cell after date \(date)")
		removeNoTasksController()
		splitView?.hidden = true
		let controller = newTaskController()
		Wireframe.presentNewTaskController(controller, overController: self, splitView: splitView!)
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		handleSettingsButton?()
	}
	
	@IBAction func handleRefreshButton(sender: NSButton) {
		reloadDataFromServer()
	}
}
