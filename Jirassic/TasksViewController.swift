//
//  TasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksViewController: NSViewController {
	
	@IBOutlet private var daysScrollView: DaysScrollView?
	@IBOutlet private var tasksScrollView: TasksScrollView?
	@IBOutlet private var _tasksTableViewWidthConstraint: NSLayoutConstraint?
	
	@IBOutlet private var _dateLabel: NSTextField?
	@IBOutlet private var _butDrawer: NSButton?
	@IBOutlet private var _butAdd: NSButton?
	@IBOutlet private var _butRefresh: NSButton?
	@IBOutlet private var _progressIndicator: NSProgressIndicator?
	
	private var _noTasksViewController: NoTasksViewController?
	private var _newTaskViewController: NewTaskViewController?
	private var _newDayController = NewDay()
	private let _gapX = CGFloat(12)
	private var kSecondaryControllerFrame = CGRect(x: 12, y: 0, width: 467, height: 379)
	
	var handleSettingsButton: (() -> ())?
	var handleRefreshButton: (() -> ())?
	var handleDrawerButton: (() -> ())?
	var handleQuitAppButton: (() -> ())?
	var selectedDate: NSDate?
	
	
	class func instanceFromStoryboard() -> TasksViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard!.instantiateControllerWithIdentifier("TasksViewController") as! TasksViewController
		return vc
	}
	
	override func awakeFromNib() {
		self.view.layer = CALayer()
		self.view.wantsLayer = true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		kSecondaryControllerFrame = NSInsetRect(self.view.bounds, _gapX, 0)
		updateNoTasksState()
		reloadDataFromServer()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		self.restoreDaysTableState()
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
				RCLogO("remove \(theData)")
			}
		}
	}
	
	func updateNoTasksState() {
		
		if tasksScrollView == nil || tasksScrollView!.data.count == 0 {
			let controller = noTasksController()
			controller.showStartState()
			self.view.addSubview( controller.view)
			_butAdd?.hidden = true
		}
		else if tasksScrollView!.data.count == 1 {
			let controller = noTasksController()
			controller.showFirstTaskState()
			_butAdd?.hidden = false
		}
		else {
			removeNoTasksController()
			_butAdd?.hidden = false
		}
	}
	
	func noTasksController() -> NoTasksViewController {
		
		if _noTasksViewController == nil {
			_noTasksViewController = NoTasksViewController.instanceFromStoryboard()
			_noTasksViewController?.view.frame = kSecondaryControllerFrame
			_noTasksViewController?.handleStartButton = { () -> Void in
				self.handleStartDayButton()
			}
		}
		
		return _noTasksViewController!
	}
	
	func removeNoTasksController() {
		if _noTasksViewController != nil {
			noTasksController().removeFromSuperview()
		}
	}
	
	func newTaskController() -> NewTaskViewController {
		
		if _newTaskViewController == nil {
			_newTaskViewController = NewTaskViewController.instanceFromStoryboard()
			_newTaskViewController?.view.frame = NSRect(x: _gapX,
				y: CGRectGetMinY(daysScrollView!.frame),
				width: self.view.frame.size.width - _gapX,
				height: CGRectGetHeight(daysScrollView!.frame))
			
			_newTaskViewController?.onOptionChosen = { (i: TaskSubtype) -> Void in
				
				self.daysScrollView?.hidden = false
				self.tasksScrollView?.hidden = false
				
				var task: TaskProtocol?
				
				switch(i) {
					case .TaskIssueBegin: task = sharedData.addNewTask(NSDate(), dateEnd: nil)
					case .TaskIssueEnd: task = sharedData.addNewTask(nil, dateEnd: NSDate())
					case .TaskScrumBegin: task = sharedData.addScrumSessionTask(nil, dateEnd:NSDate())
					case .TaskScrumEnd: task = sharedData.addScrumSessionTask(nil, dateEnd:NSDate())
					case .TaskLunchBegin: task = sharedData.addLunchBreakTask(nil, dateEnd:NSDate())
					case .TaskLunchEnd: task = sharedData.addLunchBreakTask(nil, dateEnd:NSDate())
					case .TaskMeetingBegin: task = sharedData.addLunchBreakTask(nil, dateEnd:NSDate())
					case .TaskMeetingEnd: task = sharedData.addLunchBreakTask(nil, dateEnd:NSDate())
				}
				
				self.tasksScrollView?.addTask( task! )
				WriteTask(task: task!)
				
				self.setupDaysTableView()
				self.tasksScrollView?.tableView?.insertRowsAtIndexes(NSIndexSet(index: 0),
					withAnimation: NSTableViewAnimationOptions.SlideUp)
				self.tasksScrollView?.tableView?.scrollRowToVisible( 0 )
				
				self.updateNoTasksState()
				self.removeNewTaskController()
			}
		}
		
		return _newTaskViewController!
	}
	
	func removeNewTaskController() {
		if _newTaskViewController != nil {
			newTaskController().removeFromSuperview()
		}
	}
	
	func restoreDaysTableState() {
		setDaysTableState( DrawerState().previousState() )
	}
	
	func setDaysTableState (s: DaysState) {
		
		switch s {
			case .DaysClosed:
//				_butDrawer?.image = NSImage(named: NSImageNameGoLeftTemplate)
				daysScrollView?.hidden = false
				tasksScrollView?.frame = NSRect(x: CGRectGetWidth(daysScrollView!.frame) + _gapX,
					y: CGRectGetMinY(daysScrollView!.frame),
					width: self.view.frame.size.width - CGRectGetWidth(daysScrollView!.frame) - _gapX,
					height: CGRectGetHeight(daysScrollView!.frame))
			
			case .DaysOpen:
//				_butDrawer?.image = NSImage(named: NSImageNameGoRightTemplate)
				daysScrollView?.hidden = true
				tasksScrollView?.frame = NSRect(x: _gapX,
					y: CGRectGetMinY(daysScrollView!.frame),
					width: self.view.frame.size.width - _gapX,
					height: CGRectGetHeight(daysScrollView!.frame))
		}
		
		noTasksController().view.frame = tasksScrollView!.frame
		_tasksTableViewWidthConstraint?.constant = tasksScrollView!.frame.size.width;
		
		DrawerState().setState(s)
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
		
		sharedData.queryData { (tasks, error) -> Void in
			self.reloadData()
			self.showLoadingIndicator(false)
		}
	}
	
	func reloadData() {
		self.setupDaysTableView()
		self.setupTasksTableView()
		self.reloadTasksOnDay( NSDate())
	}
	
	func reloadTasksOnDay(date: NSDate) {
		
		tasksScrollView!.data = sharedData.tasksForDayOnDate(date)
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
		
		let task = sharedData.addNewWorkingDayTask(NSDate(), dateEnd:NSDate())
		WriteTask(task: task)
		
		self._newDayController.setLastDay( NSDate())
		self.reloadData()
	}
	
	@IBAction func handleDrawerButton(sender: NSButton) {
		setDaysTableState( DrawerState().toggleState() )
	}
	
	@IBAction func handlePlusButton(sender: NSButton) {
		removeNoTasksController()
		self.daysScrollView?.hidden = true
		self.tasksScrollView?.hidden = true
		let controller = newTaskController()
		self.view.addSubview( controller.view )
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		
	}
	
	@IBAction func handleRefreshButton(sender: NSButton) {
		reloadDataFromServer()
	}
	
	@IBAction func handleQuitAppButton(sender: NSButton) {
		NSApplication.sharedApplication().terminate(nil)
	}
}
