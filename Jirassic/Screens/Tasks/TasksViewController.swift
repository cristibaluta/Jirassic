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
    
    var appWireframe: AppWireframe?
	
	private var _noTasksViewController: NoTasksViewController?
	private var _newTaskViewController: NewTaskViewController?
	private var day = NewDay()
	
	var handleSettingsButton: (() -> ())?
	var handleRefreshButton: (() -> ())?
	
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
		
		let reader = ReadDaysInteractor(data: localRepository)
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
			appWireframe?.presentNoTaskController(noTasksViewController, overController: self, splitView: splitView!)
		}
		else if tasksScrollView!.data.count == 1 {
			noTasksViewController.showFirstTaskState()
            appWireframe?.presentNoTaskController(noTasksViewController, overController: self, splitView: splitView!)
		}
		else {
			removeNoTasksController()
		}
	}
	
    
    // MARK: No Tasks
    
	var noTasksViewController: NoTasksViewController {
		
		if _noTasksViewController == nil {
			_noTasksViewController = NoTasksViewController.instantiateFromStoryboard("Main")
			_noTasksViewController?.handleStartButton = { [weak self] () -> Void in
				self?.handleStartDayButton()
			}
		}
		
		return _noTasksViewController!
	}
	
	func removeNoTasksController() {
		if let controller = _noTasksViewController {
			appWireframe?.removeController(controller)
		}
	}
	
    
    // MARK: New Tasks
    
	var newTaskViewController: NewTaskViewController {
		
		if _newTaskViewController == nil {
			_newTaskViewController = NewTaskViewController.instantiateFromStoryboard("Main")
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
				
                SaveTaskInteractor(data: localRepository).saveTask(task)
                self?.tasksScrollView?.addTask( task )
                
                self?.setupDaysTableView()
                self?.tasksScrollView?.tableView?.insertRowsAtIndexes(
                    NSIndexSet(index: 0), withAnimation: NSTableViewAnimationOptions.SlideUp)
                self?.tasksScrollView?.tableView?.scrollRowToVisible(0)
                
                self?.updateNoTasksState()
                self?.removeNewTaskController()
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
            appWireframe?.removeController(controller)
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
		localRepository.queryTasks(0, completion: { [weak self] (tasks, error) -> Void in
			self?.reloadData()
			self?.showLoadingIndicator(false)
		})
	}
	
	func reloadData() {
		self.setupDaysTableView()
		self.setupTasksTableView()
		self.reloadTasksOnDay(NSDate())
	}
	
	func reloadTasksOnDay (date: NSDate) {
		
		let reader = ReadTasksInteractor(data: localRepository)
		tasksScrollView!.data = reader.tasksInDay(date)
		tasksScrollView?.reloadData()
		tasksScrollView?.hidden = false
		
		self._dateLabel?.stringValue = date.EEEEMMdd()
		
		updateNoTasksState()
	}
	
	
	// MARK: Actions
	
	func handleStartDayButton() {
		
		let task = Task(dateSart: NSDate(), dateEnd: NSDate(), type: TaskType.Start)
		SaveTaskInteractor(data: localRepository).saveTask(task)
        self.day.setLastTrackedDay(NSDate())
        self.reloadData()
	}
	
	func handleAddTaskButton (date: NSDate) {
		RCLogO("add new cell after date \(date)")
		removeNoTasksController()
		splitView?.hidden = true
		appWireframe?.presentNewTaskController(newTaskViewController, overController: self, splitView: splitView!)
		
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
			selector: #selector(TasksViewController.newTaskWasAdded(_:)),
			name: kNewTaskWasAddedNotification,
			object: nil)
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
