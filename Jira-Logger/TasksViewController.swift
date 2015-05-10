//
//  TasksViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

enum DrawerState: Int {
	case Closed = 0
	case Open = 1
}

enum TaskSubtype: Int {
	case TaskIssueBegin = 0
	case TaskIssueEnd = 1
	case TaskScrumBegin = 2
	case TaskScrumEnd = 3
	case TaskLunchBegin = 4
	case TaskLunchEnd = 5
}

class TasksViewController: NSViewController {
	
	@IBOutlet private var _datesScrollView: NSScrollView?
	@IBOutlet private var _tasksScrollView: NSScrollView?
	@IBOutlet private var _datesTableView: NSTableView?
	@IBOutlet private var _tasksTableView: NSTableView?
	
	private var _noTasksViewController: NoTasksViewController?
	private var _newTaskViewController: NewTaskViewController?
	
	@IBOutlet private var _dateLabel: NSTextField?
	@IBOutlet private var _butDrawer: NSButton?
	@IBOutlet private var _butAdd: NSButton?
	@IBOutlet private var _progressIndicator: NSProgressIndicator?
	
	private var _dateCellDatasource: DateCellDataSource?
	private var _taskCellDatasource: TaskCellDataSource?
	private var _newDayController = NewDayController()
	private var _state: DrawerState = .Open
	private let _gapX = CGFloat(12)
	private let kDrawerStateKey = "DrawerStateKey"
	private let kSecondaryControllerFrame = CGRect(x: 12, y: 0, width: 467, height: 379)
	
    override func viewDidLoad() {
		
        super.viewDidLoad()
		updateNoTasksState()
		
		sharedData.queryData { (tasks, error) -> Void in
			self.reloadData()
		}
		
		SleepNotifications()
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		self.setPreviousDrawerState()
		if _newDayController.isNewDay() {
			reloadData()
		}
	}
	
	override func viewDidDisappear() {
		super.viewDidDisappear()
	}
	
	func reloadData() {
		self.setupDaysTableView()
		self.setupTasksTableView()
		self.reloadTasksOnDay( NSDate())
	}
	
	func setupDaysTableView() {
		
		if _dateCellDatasource == nil {
			_dateCellDatasource = DateCellDataSource()
			_dateCellDatasource!.tableView = _datesTableView
			_dateCellDatasource!.data = sharedData.days()
			_dateCellDatasource?.didSelectRow = { (row: Int) in
				if row >= 0 {
					let theData = self._dateCellDatasource!.data![row]
					self.reloadTasksOnDay( theData.date_task_finished!)
				}
			}
			
			_datesTableView?.setDataSource( _dateCellDatasource )
			_datesTableView?.setDelegate( _dateCellDatasource )
		} else {
			_dateCellDatasource!.data = sharedData.days()
		}
	}
	
	func setupTasksTableView() {
		
		if _taskCellDatasource == nil {
			_taskCellDatasource = TaskCellDataSource()
			_taskCellDatasource!.tableView = _tasksTableView
			_taskCellDatasource!.didRemoveRow = { (row: Int) in
				RCLogO("remove \(row)")
				if row >= 0 {
					let theData = self._taskCellDatasource!.data![row]
					RCLogO("remove \(theData)")
				}
			}
			
			_tasksTableView?.setDataSource( _taskCellDatasource )
			_tasksTableView?.setDelegate( _taskCellDatasource )
		}
	}
	
	func reloadTasksOnDay(date: NSDate) {
		
		_taskCellDatasource!.data = sharedData.tasksForDayOnDate(date)
		_tasksTableView?.reloadData()
		_tasksTableView?.hidden = false
		
		_dateLabel?.stringValue = date.EEEEMMdd()
		
		updateNoTasksState()
	}
	
	func updateNoTasksState() {
		
		if _taskCellDatasource == nil || _taskCellDatasource!.data?.count == 0 {
			let controller = noTasksController()
			controller.showStartState()
			self.view.addSubview( controller.view)
			_butAdd?.hidden = true
		}
		else if _taskCellDatasource!.data?.count == 1 {
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
			_noTasksViewController?.onButStartPressed = { () -> Void in
				
				let task = sharedData.addNewWorkingDayTask()
				JLTaskWriter().write( task )
				
				self._newDayController.setLastDay( NSDate())
				self.reloadData()
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
			_newTaskViewController?.view.frame = kSecondaryControllerFrame
			_newTaskViewController?.onOptionChosen = { (i: TaskSubtype) -> Void in
				
				self._datesTableView?.hidden = false
				self._tasksTableView?.hidden = false
				
				var task: Task?
				
				switch(i) {
				case .TaskIssueBegin, .TaskIssueEnd:
					task = sharedData.addNewTask()
				case .TaskScrumBegin, .TaskScrumEnd:
					task = sharedData.addScrumSessionTask()
				case .TaskLunchBegin, .TaskLunchEnd:
					task = sharedData.addLunchBreakTask()
				}
				RCLogO(task)
				self._taskCellDatasource?.addTask( task! )
				JLTaskWriter().write( task! )
				
				self._tasksTableView?.insertRowsAtIndexes(NSIndexSet(index: 0),
					withAnimation: NSTableViewAnimationOptions.SlideUp)
				self._tasksTableView?.scrollRowToVisible( 0 )
				
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
	
	func setPreviousDrawerState() {
		let previousState = NSUserDefaults.standardUserDefaults().integerForKey(kDrawerStateKey)
		setDrawerState( previousState == 0 ? .Closed : .Open)
	}
	
	func setDrawerState (s: DrawerState) {
		
		_state = s
		
		switch s {
		case .Closed:
			_butDrawer?.image = NSImage(named: NSImageNameGoLeftTemplate)
			_datesScrollView?.hidden = false
			_tasksScrollView?.frame = NSRect(x: CGRectGetWidth(_datesScrollView!.frame) + _gapX,
				y: CGRectGetMinY(_tasksScrollView!.frame),
				width: self.view.frame.size.width - CGRectGetWidth(_datesScrollView!.frame) - _gapX,
				height: CGRectGetHeight(_datesScrollView!.frame))
			
		case .Open:
			_butDrawer?.image = NSImage(named: NSImageNameGoRightTemplate)
			_datesScrollView?.hidden = true
			_tasksScrollView?.frame = NSRect(x: _gapX,
				y: CGRectGetMinY(_datesScrollView!.frame),
				width: self.view.frame.size.width - _gapX,
				height: CGRectGetHeight(_datesScrollView!.frame))
		default:
			_datesScrollView?.hidden = true
		}
		
		NSUserDefaults.standardUserDefaults().setInteger(_state.rawValue, forKey: kDrawerStateKey)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	
	// MARK: Actions
	
	@IBAction func handleColumnButton(sender: NSButton) {
		setDrawerState( _state == .Closed ? .Open : .Closed)
	}
	
	@IBAction func handlePlusButton(sender: NSButton) {
		removeNoTasksController()
		_datesTableView?.hidden = true
		_tasksTableView?.hidden = true
		let controller = newTaskController()
		self.view.addSubview( controller.view)
	}
	
	@IBAction func handleRemoveButton(sender: NSButton) {
//		_taskCellDatasource?.addObjectWithDate( NSDate())
		_tasksTableView?.removeRowsAtIndexes(NSIndexSet(index: 0), withAnimation: NSTableViewAnimationOptions.SlideRight)
	}
	
	@IBAction func handleShareButton(sender: NSButton) {
		
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		
	}
}
