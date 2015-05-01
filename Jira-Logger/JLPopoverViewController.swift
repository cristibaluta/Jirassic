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
	
	@IBOutlet var _datesScrollView: NSScrollView?
	@IBOutlet var _tasksScrollView: NSScrollView?
	@IBOutlet var _datesTableView: NSTableView?
	@IBOutlet var _tasksTableView: NSTableView?
	@IBOutlet var _noTasksLabel: NSTextField?
	@IBOutlet var _dateLabel: NSTextField?
	@IBOutlet var _butDrawer: NSButton?
	var _dateCellDatasource: DateCellDataSource?
	var _taskCellDatasource: TaskCellDataSource?
	var _state: DrawerState = .Open
	let _gapX = CGFloat(12)
	let kDrawerStateKey = "DrawerStateKey"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Setup delegates for all tableViews
		setupDatesTableView()
		setupTasksTableView()
		
		reloadDataForTasksOnDate( NSDate())
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		let previousState = NSUserDefaults.standardUserDefaults().integerForKey(kDrawerStateKey)
		RCLogO(previousState)
		if previousState != self._state.rawValue {
			self._state = .Open
		}
		RCLogO(self._state.rawValue)
		setState( self._state)
	}
	
	func setupDatesTableView() {
		
		_dateCellDatasource = DateCellDataSource()
		_dateCellDatasource!.tableView = _datesTableView
		_dateCellDatasource!.data = DummyDataManager.dates()
		_dateCellDatasource?.didSelectRow = { (row: Int) in
			let theData = self._dateCellDatasource!.data![row]
			RCLogO(theData)
			self.reloadDataForTasksOnDate( theData.date_task_finished!)
		}
		
//		_datesTableView?.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
		_datesTableView?.setDataSource( _dateCellDatasource )
		_datesTableView?.setDelegate( _dateCellDatasource )
	}
	
	func setupTasksTableView() {
		
		_taskCellDatasource = TaskCellDataSource()
		_taskCellDatasource!.tableView = _tasksTableView
		
		_tasksTableView?.setDataSource( _taskCellDatasource )
		_tasksTableView?.setDelegate( _taskCellDatasource )
	}
	
	func reloadDataForTasksOnDate(date: NSDate) {
		
		_noTasksLabel?.hidden = true
		
		_taskCellDatasource!.data = DummyDataManager.tasksForDate(date)
		_tasksTableView?.reloadData()
		
		_dateLabel?.stringValue = date.EEEEMMdd()
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
		RCLogRect(_tasksScrollView?.frame)
	}
	
	
	// MARK: Actions
	
	@IBAction func handleColumnButton(sender: NSButton) {
		
		setState( _state == .Closed ? .Open : .Closed)
		
		NSUserDefaults.standardUserDefaults().setInteger(_state.rawValue, forKey: kDrawerStateKey)
		NSUserDefaults.standardUserDefaults().synchronize()
		RCLogO(_state.rawValue)
	}
	
	@IBAction func handlePlusButton(sender: NSButton) {
		_taskCellDatasource?.addObjectWithDate( NSDate())
		_tasksTableView?.reloadData()
		_tasksTableView?.scrollColumnToVisible( 0 )
	}
	
	@IBAction func handleShareButton(sender: NSButton) {
		
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		
	}
}
