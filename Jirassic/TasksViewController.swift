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
	@IBOutlet private var datesScrollView: DatesScrollView?
	@IBOutlet private var tasksScrollView: TasksScrollView?
	@IBOutlet private var _dateLabel: NSTextField?
	@IBOutlet private var _butRefresh: NSButton?
	@IBOutlet private var _progressIndicator: NSProgressIndicator?
	@IBOutlet private var butShare: NSButton?
	
	private var _noTasksViewController: NoTasksViewController?
	private var _newTaskViewController: NewTaskViewController?
	private var day = NewDay()
	
	var handleSettingsButton: (() -> ())?
	var handleRefreshButton: (() -> ())?
	
    
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
		registerForNotifications()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		if day.isNewDay() {
			reloadData()
		}
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
    
    // MARK: Setup
    
	func setupDaysTableView() {
		
		let reader = ReadDaysInteractor(data: sharedData)
		datesScrollView?.weeks = reader.weeks()
		datesScrollView?.didSelectDay = { [weak self] (day: Day) in
			self?.reloadTasksOnDay(day.date)
		}
		datesScrollView?.reloadData()
	}
	
	func setupTasksTableView() {
		
		tasksScrollView!.didRemoveRow = { (row: Int) in
			RCLogO("remove item at row \(row)")
			if row >= 0 {
                self.tasksScrollView!.removeTaskAtRow(row);
			}
		}
		tasksScrollView!.didAddRow = { [weak self] (row: Int) -> Void in
			RCLogO("add item after row \(row)")
			let theData = self?.tasksScrollView!.data[row]
            if let date = theData?.endDate {
                self?.handleAddTaskButton(date)
            }
		}
	}
	
	func updateNoTasksState() {
		
		if tasksScrollView!.data.count == 0 {
			noTasksViewController.showStartState()
			Wireframe.presentNoTaskController(noTasksViewController, overController: self, splitView: splitView!)
		}
		else if tasksScrollView!.data.count == 1 {
			noTasksViewController.showFirstTaskState()
            Wireframe.presentNoTaskController(noTasksViewController, overController: self, splitView: splitView!)
		}
		else {
			removeNoTasksController()
		}
	}
	
    
    // MARK: No Tasks
    
	var noTasksViewController: NoTasksViewController {
		
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
    
	var newTaskViewController: NewTaskViewController {
		
		if _newTaskViewController == nil {
			_newTaskViewController = NewTaskViewController.instanceFromStoryboard()
			_newTaskViewController?.onOptionChosen = { [weak self] (i: TaskSubtype) -> Void in
				
				self?.splitView?.hidden = false
				
				var task = Task(subtype: i)
				task.notes = self!._newTaskViewController!.notes
				task.issueType = self!._newTaskViewController!.issueType
				task.issueId = self!._newTaskViewController!.issueId
				if task.endDate != nil {
					task.endDate = self!._newTaskViewController!.date
				} else if task.startDate != nil {
					task.startDate = self!._newTaskViewController!.date
				}
				RCLog(task)
				sharedData.updateTask(task, completion: {(success: Bool) -> Void in
					
					self?.tasksScrollView?.addTask( task )
					
					self?.setupDaysTableView()
					self?.tasksScrollView?.tableView?.insertRowsAtIndexes(NSIndexSet(index: 0),
						withAnimation: NSTableViewAnimationOptions.SlideUp)
					self?.tasksScrollView?.tableView?.scrollRowToVisible(0)
					
					self?.updateNoTasksState()
					self?.removeNewTaskController()
				})
			}
			_newTaskViewController?.onCancelChosen = {
				self.splitView?.hidden = false
				self.removeNewTaskController()
			}
		}
		
		return _newTaskViewController!
	}
	
	func removeNewTaskController() {
        if let controller = _newTaskViewController {
            Wireframe.removeController(controller)
        }
	}
	
	func showLoadingIndicator (show: Bool) {
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
			self?.reloadData()
			self?.showLoadingIndicator(false)
		}
	}
	
	func reloadData() {
		self.setupDaysTableView()
		self.setupTasksTableView()
		self.reloadTasksOnDay(NSDate())
	}
	
	func reloadTasksOnDay (date: NSDate) {
		
		let reader = ReadDayInteractor(data: sharedData)
		tasksScrollView!.data = reader.tasksForDayOfDate(date)
		tasksScrollView?.reloadData()
		tasksScrollView?.hidden = false
		
		self._dateLabel?.stringValue = date.EEEEMMdd()
		
		updateNoTasksState()
	}
	
	
	// MARK: Actions
	
	func handleStartDayButton() {
		
		let task = Task(dateSart: NSDate(), dateEnd: NSDate(), type: TaskType.Start)
		sharedData.updateTask(task, completion: { [weak self] (success: Bool) -> Void in
			self?.day.setLastTrackedDay(NSDate())
			self?.reloadData()
		})
	}
	
	func handleAddTaskButton (date: NSDate) {
		RCLogO("add new cell after date \(date)")
		removeNoTasksController()
		splitView?.hidden = true
		Wireframe.presentNewTaskController(newTaskViewController, overController: self, splitView: splitView!)
		
		newTaskViewController.date = NSDate()
	}
	
	@IBAction func handleSettingsButton (sender: NSButton) {
		handleSettingsButton?()
	}
	
	@IBAction func handleRefreshButton (sender: NSButton) {
		reloadDataFromServer()
	}
	
	@IBAction func handleShareButton (sender: NSButton) {
		
		let report = CreateReport(tasks: tasksScrollView!.data.reverse())
		report.round()
		tasksScrollView!.data = report.tasks.reverse()
		tasksScrollView?.reloadData()
	}
}

extension TasksViewController {
	
	func registerForNotifications() {
		
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: Selector("newTaskWasAdded:"), name: kNewTaskWasAddedNotification, object: nil)
	}
	
	func newTaskWasAdded (notif: NSNotification) {
		
		if let task = notif.object as? Task {
			self.tasksScrollView?.addTask( task )
			self.tasksScrollView?.tableView?.insertRowsAtIndexes(NSIndexSet(index: 0),
				withAnimation: NSTableViewAnimationOptions.SlideUp)
			self.tasksScrollView?.tableView?.scrollRowToVisible( 0 )
			self.updateNoTasksState()
		}
	}
}
