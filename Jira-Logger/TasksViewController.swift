//
//  TasksViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

enum TaskSubtype: Int {
	case TaskIssueBegin = 0
	case TaskIssueEnd = 1
	case TaskScrumBegin = 2
	case TaskScrumEnd = 3
	case TaskLunchBegin = 4
	case TaskLunchEnd = 5
	case TaskMeetingBegin = 6
	case TaskMeetingEnd = 7
}

class TasksViewController: NSViewController {
	
	@IBOutlet private var _datesScrollView: NSScrollView?
	@IBOutlet private var _tasksScrollView: NSScrollView?
	@IBOutlet private var _datesTableView: NSTableView?
	@IBOutlet private var _tasksTableView: NSTableView?
	@IBOutlet private var _tasksTableViewWidthConstraint: NSLayoutConstraint?
	
	@IBOutlet private var _dateLabel: NSTextField?
	@IBOutlet private var _butDrawer: NSButton?
	@IBOutlet private var _butAdd: NSButton?
	@IBOutlet private var _butRefresh: NSButton?
	@IBOutlet private var _progressIndicator: NSProgressIndicator?
	
	private var _noTasksViewController: NoTasksViewController?
	private var _newTaskViewController: NewTaskViewController?
	
	private var _daysDataSource: DaysDataSource?
	private var _tasksDataSource: TasksDataSource?
	private var _newDayController = NewDayController()
	private let _gapX = CGFloat(12)
	private var kSecondaryControllerFrame = CGRect(x: 12, y: 0, width: 467, height: 379)
	
	var onButSettingsPressed: (() -> ())?
	
	
	class func instanceFromStoryboard() -> TasksViewController {
		let storyboard = NSStoryboard(name: "Main", bundle: nil)
		let vc = storyboard!.instantiateControllerWithIdentifier("TasksViewController") as! TasksViewController
		return vc
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
	}
	
	override func viewDidDisappear() {
		super.viewDidDisappear()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
	}
	
	override func awakeFromNib() {
		self.view.layer = CALayer()
		self.view.wantsLayer = true
	}
	
	func removeFromSuperview() {
		self.view.removeFromSuperview()
	}
	
	func reloadDataFromServer() {
		self._progressIndicator?.startAnimation(nil)
		self._butRefresh?.hidden = true
		sharedData.queryData { (tasks, error) -> Void in
			self.reloadData()
			self._progressIndicator?.stopAnimation(nil)
			self._butRefresh?.hidden = false
		}
	}
	
	func reloadData() {
		self.setupDaysTableView()
		self.setupTasksTableView()
		self.reloadTasksOnDay( NSDate())
	}
	
	func setupDaysTableView() {
		
		if _daysDataSource == nil {
			_daysDataSource = DaysDataSource()
			_daysDataSource!.tableView = _datesTableView
			_daysDataSource!.data = sharedData.days()
			_daysDataSource?.didSelectRow = { (row: Int) in
				if row >= 0 {
					let theData = self._daysDataSource!.data![row]
					if let dateEnd = theData.date_task_finished {
						self.reloadTasksOnDay( dateEnd )
					} else if let dateStart = theData.date_task_started {
						self.reloadTasksOnDay( dateStart )
					}
				}
			}
			
			_datesTableView?.setDataSource( _daysDataSource )
			_datesTableView?.setDelegate( _daysDataSource )
		} else {
			_daysDataSource!.data = sharedData.days()
		}
		_datesTableView?.reloadData()
	}
	
	func setupTasksTableView() {
		
		if _tasksDataSource == nil {
			_tasksDataSource = TasksDataSource()
			_tasksDataSource!.tableView = _tasksTableView
			_tasksDataSource!.didRemoveRow = { (row: Int) in
				RCLogO("remove \(row)")
				if row >= 0 {
					let theData = self._tasksDataSource!.data![row]
					RCLogO("remove \(theData)")
				}
			}
			
			_tasksTableView?.setDataSource( _tasksDataSource )
			_tasksTableView?.setDelegate( _tasksDataSource )
		}
	}
	
	func reloadTasksOnDay(date: NSDate) {
		
		_tasksDataSource!.data = sharedData.tasksForDayOnDate(date)
		_tasksTableView?.reloadData()
		_tasksTableView?.hidden = false
		
		_dateLabel?.stringValue = date.EEEEMMdd()
		
		updateNoTasksState()
	}
	
	func updateNoTasksState() {
		
		if _tasksDataSource == nil || _tasksDataSource!.data?.count == 0 {
			let controller = noTasksController()
			controller.showStartState()
			self.view.addSubview( controller.view)
			_butAdd?.hidden = true
		}
		else if _tasksDataSource!.data?.count == 1 {
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
				
				let task = sharedData.addNewWorkingDayTask(NSDate(), dateEnd:NSDate())
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
			_newTaskViewController?.view.frame = NSRect(x: _gapX,
				y: CGRectGetMinY(_datesScrollView!.frame),
				width: self.view.frame.size.width - _gapX,
				height: CGRectGetHeight(_datesScrollView!.frame))
			_newTaskViewController?.onOptionChosen = { (i: TaskSubtype) -> Void in
				
				self._datesTableView?.hidden = false
				self._tasksTableView?.hidden = false
				
				var task: Task?
				
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
				
				self._tasksDataSource?.addTask( task! )
				JLTaskWriter().write( task! )
				
				self.setupDaysTableView()
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
	
	func restoreDaysTableState() {
		setDaysTableState( JLDrawerState().previousState() )
	}
	
	func setDaysTableState (s: DaysState) {
		
		switch s {
			case .DaysClosed:
				_butDrawer?.image = NSImage(named: NSImageNameGoLeftTemplate)
				_datesScrollView?.hidden = false
				_tasksScrollView?.frame = NSRect(x: CGRectGetWidth(_datesScrollView!.frame) + _gapX,
					y: CGRectGetMinY(_datesScrollView!.frame),
					width: self.view.frame.size.width - CGRectGetWidth(_datesScrollView!.frame) - _gapX,
					height: CGRectGetHeight(_datesScrollView!.frame))
			
			case .DaysOpen:
				_butDrawer?.image = NSImage(named: NSImageNameGoRightTemplate)
				_datesScrollView?.hidden = true
				_tasksScrollView?.frame = NSRect(x: _gapX,
					y: CGRectGetMinY(_datesScrollView!.frame),
					width: self.view.frame.size.width - _gapX,
					height: CGRectGetHeight(_datesScrollView!.frame))
		}
		
		noTasksController().view.frame = _tasksScrollView!.frame
		_tasksTableViewWidthConstraint?.constant = _tasksScrollView!.frame.size.width;
		
		JLDrawerState().setState(s)
	}
	
	
	// MARK: Actions
	
	@IBAction func handleColumnButton(sender: NSButton) {
		setDaysTableState( JLDrawerState().toggleState() )
	}
	
	@IBAction func handlePlusButton(sender: NSButton) {
		removeNoTasksController()
		_datesTableView?.hidden = true
		_tasksTableView?.hidden = true
		let controller = newTaskController()
		self.view.addSubview( controller.view )
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		self.onButSettingsPressed!()
	}
	
	@IBAction func handleRefreshButton(sender: NSButton) {
		reloadDataFromServer()
	}
}
