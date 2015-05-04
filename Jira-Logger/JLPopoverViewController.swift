//
//  JLPopoverViewController.swift
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

class JLPopoverViewController: NSViewController {
	
	@IBOutlet private var _datesScrollView: NSScrollView?
	@IBOutlet private var _tasksScrollView: NSScrollView?
	@IBOutlet private var _datesTableView: NSTableView?
	@IBOutlet private var _tasksTableView: NSTableView?
	
	@IBOutlet private var _noTasksContainer: NSView?
	@IBOutlet private var _noTasksLabel: NSTextField?
	@IBOutlet private var _butStart: NSButton?
	
	@IBOutlet private var _dateLabel: NSTextField?
	@IBOutlet private var _butDrawer: NSButton?
	@IBOutlet private var _butAdd: NSButton?
	private var _dateCellDatasource: DateCellDataSource?
	private var _taskCellDatasource: TaskCellDataSource?
	private var _state: DrawerState = .Open
	private let _gapX = CGFloat(12)
	private let kDrawerStateKey = "DrawerStateKey"
	
    override func viewDidLoad() {
		
        super.viewDidLoad()
		updateNoTasksState()
		
		sharedData.queryData { (tasks, error) -> Void in
			self.reloadData()
		}
    }
	
	override func viewDidAppear() {
		RCLogO("viewDidAppear")
		super.viewDidAppear()
		
		let previousState = NSUserDefaults.standardUserDefaults().integerForKey(kDrawerStateKey)
		if previousState != self._state.rawValue {
			self._state = .Open
		}
		setState( self._state)
	}
	
	override func viewDidDisappear() {
		RCLogO("viewDidDisappear")
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
			
			_tasksTableView?.setDataSource( _taskCellDatasource )
			_tasksTableView?.setDelegate( _taskCellDatasource )
		}
	}
	
	func reloadTasksOnDay(date: NSDate) {
		
		_taskCellDatasource!.data = sharedData.tasksForDayOnDate(date).reverse()
		_tasksTableView?.reloadData()
		
		_dateLabel?.stringValue = date.EEEEMMdd()
		
		updateNoTasksState()
	}
	
	func updateNoTasksState() {
		
		if _taskCellDatasource == nil || _taskCellDatasource!.data?.count == 0 {
			_noTasksContainer?.hidden = false
			_butAdd?.hidden = true
			_noTasksLabel?.stringValue = NoTasksController().showStartState()
		} else {
			_noTasksContainer?.hidden = true
			_butAdd?.hidden = false
		}
	}
	
	func setState (s: DrawerState) {
		
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
	}
	
	
	// MARK: Actions
	
	@IBAction func handleColumnButton(sender: NSButton) {
		
		setState( _state == .Closed ? .Open : .Closed)
		
		NSUserDefaults.standardUserDefaults().setInteger(_state.rawValue, forKey: kDrawerStateKey)
		NSUserDefaults.standardUserDefaults().synchronize()
		RCLogO(_state.rawValue)
	}
	
	@IBAction func handlePlusButton(sender: NSButton) {
		
		let task = sharedData.addNewTask()
		_taskCellDatasource?.addTask( task )
		
		let index = _taskCellDatasource!.data!.count - 1
		_tasksTableView?.insertRowsAtIndexes(NSIndexSet(index: index), withAnimation: NSTableViewAnimationOptions.SlideDown)
		_tasksTableView?.scrollRowToVisible( index )
	}
	
	@IBAction func handleRemoveButton(sender: NSButton) {
//		_taskCellDatasource?.addObjectWithDate( NSDate())
		_tasksTableView?.removeRowsAtIndexes(NSIndexSet(index: 0), withAnimation: NSTableViewAnimationOptions.SlideRight)
	}
	
	@IBAction func handleShareButton(sender: NSButton) {
		
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		
	}
	
	@IBAction func handleStartButton(sender: NSButton) {
		
		let task = sharedData.addNewTask()
		task.task_nr = "Start"
		task.notes = "Working day started at \(NSDate())"
		
		self.reloadData()
	}
	
}
