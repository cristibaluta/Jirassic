//
//  TasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksViewController: NSViewController {
	
	@IBOutlet private weak var splitView: NSSplitView!
	@IBOutlet private weak var calendarScrollView: CalendarScrollView!
	private var tasksScrollView: TasksScrollView?
    @IBOutlet private weak var listSegmentedControl: NSSegmentedControl!
    @IBOutlet private weak var butRefresh: NSButton!
    @IBOutlet private weak var butSettings: NSButton!
    @IBOutlet private weak var butQuit: NSButton!
    @IBOutlet private weak var butMinimize: NSButton!
    @IBOutlet private weak var refreshIndicator: NSProgressIndicator!
    
    weak var appWireframe: AppWireframe?
    var presenter: TasksPresenterInput?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		createLayer()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		registerForNotifications()
        listSegmentedControl!.selectedSegment = TaskTypeSelection().lastType().rawValue
        hideControls(false)
        
        calendarScrollView!.didSelectDay = { [weak self] (day: Day) in
            self?.presenter!.reloadTasksOnDay(day, listType: ListType(rawValue: (self?.listSegmentedControl!.selectedSegment)!)!)
        }
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
        presenter!.initUI()
	}
	
    deinit {
        RCLog(self)
		NotificationCenter.default.removeObserver(self)
	}
    
    private func hideControls (_ hide: Bool) {
        butSettings.isHidden = hide
        butRefresh.isHidden = remoteRepository == nil ? true : hide
        butQuit.isHidden = hide
        butMinimize.isHidden = hide
        listSegmentedControl.isHidden = hide
    }
}

extension TasksViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

extension TasksViewController {
	
	@IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        let listType = ListType(rawValue: sender.selectedSegment)!
        TaskTypeSelection().setType(listType)
        if let selectedDay = calendarScrollView!.selectedDay {
            presenter!.reloadTasksOnDay(selectedDay, listType: listType)
        }
	}
    
    @IBAction func handleRefreshButton (_ sender: NSButton) {
        presenter!.syncData()
    }
    
    @IBAction func handleSettingsButton (_ sender: NSButton) {
        appWireframe!.flipToSettingsController()
    }
    
    @IBAction func handleQuitAppButton (_ sender: NSButton) {
        NSApplication.shared.terminate(nil)
    }
    
    @IBAction func handleMinimizeAppButton (_ sender: NSButton) {
        AppDelegate.sharedApp().menu.triggerClose()
    }
}

extension TasksViewController: TasksPresenterOutput {
    
    func showLoadingIndicator (_ show: Bool) {
        
        butRefresh!.isHidden = remoteRepository == nil ? true : show
        if show {
            refreshIndicator.startAnimation(nil)
        } else {
            refreshIndicator.stopAnimation(nil)
        }
    }
    
    func showMessage (_ message: MessageViewModel) {
        
        let controller = appWireframe!.presentPlaceholder(message, intoSplitView: splitView!)
        controller.didPressButton = {
            self.presenter?.messageButtonDidPress()
        }
    }
    
    func showCalendar (_ weeks: [Week]) {
        
        calendarScrollView.weeks = weeks
        calendarScrollView.reloadData()
    }
    
    func showTasks (_ tasks: [Task]) {
        
        if tasksScrollView != nil {
            tasksScrollView?.removeFromSuperview()
            tasksScrollView = nil
        }
        var r = splitView!.subviews[SplitViewColumn.tasks.rawValue].frame
        r.origin = NSPoint.zero
        tasksScrollView = TasksScrollView(tasks: tasks)
        tasksScrollView!.frame = r
        splitView.subviews[SplitViewColumn.tasks.rawValue].addSubview(tasksScrollView!)
        tasksScrollView!.constrainToSuperview()
        tasksScrollView!.didRemoveRow = { [weak self] (row: Int) in
            RCLogO("Remove item at row \(row)")
            if row >= 0 {
                self?.presenter!.removeTaskAtRow(row)
                self?.tasksScrollView!.removeTaskAtRow(row)
            }
        }
        tasksScrollView!.didAddRow = { [weak self] (row: Int) -> Void in
            RCLogO("Add item after row \(row)")
            if row >= 0 {
                self?.presenter!.insertTaskAfterRow(row)
            }
        }
        tasksScrollView!.didEndDay = { [weak self] (_ tasks: [Task]) -> Void in
            self?.presenter!.endDay()
        }
        
        tasksScrollView!.reloadData()
        tasksScrollView!.isHidden = false
    }
    
    func showReports (_ reports: [Report]) {
        
        if tasksScrollView != nil {
            tasksScrollView?.removeFromSuperview()
            tasksScrollView = nil
        }
        var r = splitView.subviews[SplitViewColumn.tasks.rawValue].frame
        r.origin = NSPoint.zero
        tasksScrollView = TasksScrollView(reports: reports)
        tasksScrollView!.frame = r
        splitView!.subviews[SplitViewColumn.tasks.rawValue].addSubview(tasksScrollView!)
        tasksScrollView!.constrainToSuperview()
        tasksScrollView!.reloadData()
        tasksScrollView!.isHidden = false
        tasksScrollView!.didChangeSettings = { [weak self] in
            if let strongSelf = self {
                strongSelf.handleSegmentedControl(strongSelf.listSegmentedControl)
            }
        }
    }
    
    func selectDay (_ day: Day) {
        calendarScrollView.selectDay(day)
    }
    
    func presentNewTaskController (withInitialDate date: Date) {
        
        splitView.isHidden = true
        appWireframe!.removePlaceholder()
        hideControls(true)
        
        let controller = appWireframe!.presentNewTaskController()
        controller.dateStart = nil// TODO Add scrum start date when around scrum date
        controller.dateEnd = date
        controller.onSave = { [weak self] (taskData: TaskCreationData) -> Void in
            if let strongSelf = self {
                strongSelf.presenter!.insertTaskWithData(taskData)
                strongSelf.presenter!.updateNoTasksState()
                strongSelf.presenter!.reloadData()
                strongSelf.appWireframe!.removeNewTaskController()
                strongSelf.splitView.isHidden = false
                strongSelf.hideControls(false)
            }
        }
        controller.onCancel = { [weak self] in
            if let strongSelf = self {
                strongSelf.appWireframe!.removeNewTaskController()
                strongSelf.splitView.isHidden = false
                strongSelf.presenter!.updateNoTasksState()
                strongSelf.hideControls(false)
            }
        }
    }

    func presentEndDayController (date: Date, tasks: [Task]) {

        splitView.isHidden = true
        appWireframe!.removePlaceholder()
        hideControls(true)

        let controller = appWireframe!.presentEndDayController(date: date, tasks: tasks)
        controller.onSave = { [weak self] in
            if let strongSelf = self {
                strongSelf.presenter!.updateNoTasksState()
                strongSelf.appWireframe!.removeEndDayController()
                strongSelf.splitView.isHidden = false
                strongSelf.hideControls(false)
            }
        }
        controller.onCancel = { [weak self] in
            if let strongSelf = self {
                strongSelf.appWireframe!.removeEndDayController()
                strongSelf.splitView.isHidden = false
                strongSelf.presenter!.updateNoTasksState()
                strongSelf.hideControls(false)
            }
        }
    }
}

extension TasksViewController {
	
	func registerForNotifications() {
		
		NotificationCenter.default.addObserver(self,
			selector: #selector(TasksViewController.handleNewTaskAdded(_:)),
			name: NSNotification.Name(rawValue: kNewTaskWasAddedNotification),
			object: nil)
	}
	
	@objc func handleNewTaskAdded (_ notif: Notification) {
        presenter!.reloadData()
	}
}
