//
//  JLPopoverViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class JLPopoverViewController: NSViewController {
	
	@IBOutlet var _datesScrollView: NSScrollView?
	@IBOutlet var _tasksScrollView: NSScrollView?
	@IBOutlet var _datesTableView: NSTableView?
	@IBOutlet var _tasksTableView: NSTableView?
	@IBOutlet var _noTasksLabel: NSTextField?
	@IBOutlet var _dateLabel: NSTextField?
	var _dateCellDatasource: DateCellDataSource?
	var _taskCellDatasource: TaskCellDataSource?
	var _state: Int = 1
	let _gapX = CGFloat(12)
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Setup delegates for all tableViews
		setupDatesTableView()
		setupTasksTableView()
		
		reloadDataForTasksOnDate( NSDate())
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
		setState( _state)
	}
	
	func setupDatesTableView() {
		
		_dateCellDatasource = DateCellDataSource()
		_dateCellDatasource!.tableView = _datesTableView
		_dateCellDatasource!.data = DummyDataManager.dates()
		_dateCellDatasource?.didSelectRow = { (row: Int) in
			self.reloadDataForTasksOnDate( NSDate())
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
		
		_taskCellDatasource!.data = DummyDataManager.data()
		_tasksTableView?.reloadData()
	}
	
	func setState (s: Int) {
		
		_state = s
		
		switch s {
		case 0:
			
			_datesScrollView?.hidden = false
			_tasksScrollView?.frame = NSRect(x: CGRectGetWidth(_datesScrollView!.frame) + _gapX,
				y: CGRectGetMinY(_tasksScrollView!.frame),
				width: self.view.frame.size.width - CGRectGetWidth(_datesScrollView!.frame) - _gapX,
				height: CGRectGetHeight(_datesScrollView!.frame))
		case 1:
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
	
	
	// Actions
	
	@IBAction func handleColumnButton(sender: NSButton) {
		setState( _state == 0 ? 1 : 0)
	}
	
	@IBAction func handlePlusButton(sender: NSButton) {
		RCLogO(sender)
		_taskCellDatasource?.addObjectWithDate( NSDate())
		_tasksTableView?.reloadData()
		_tasksTableView?.scrollColumnToVisible( 0 )
	}
	
	@IBAction func handleShareButton(sender: NSButton) {
		
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		
	}
}
