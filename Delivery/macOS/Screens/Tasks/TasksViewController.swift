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
    @IBOutlet private weak var loadingTasksIndicator: NSProgressIndicator!
    @IBOutlet private weak var syncIndicator: NSProgressIndicator!
    
    weak var appWireframe: AppWireframe?
    var presenter: TasksPresenterInput?
    private var rectToDisplayPopoverAt: NSRect?
    private var activePopover: NSPopover?
	
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
            guard let strongSelf = self else {
                return
            }
            let selectedListType = ListType(rawValue: strongSelf.listSegmentedControl!.selectedSegment)!
            strongSelf.presenter!.reloadTasksOnDay(day, listType: selectedListType)
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
        
        butRefresh.isHidden = remoteRepository == nil ? true : show
        if show {
            loadingTasksIndicator.isHidden = false
            loadingTasksIndicator.startAnimation(nil)
        } else {
            loadingTasksIndicator.stopAnimation(nil)
            loadingTasksIndicator.isHidden = true
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
        
        var frame = splitView!.subviews[SplitViewColumn.tasks.rawValue].frame
        frame.origin = NSPoint.zero
        let scrollView = TasksScrollView(tasks: tasks)
        scrollView.frame = frame
        splitView.subviews[SplitViewColumn.tasks.rawValue].addSubview(scrollView)
        scrollView.constrainToSuperview()
        scrollView.didRemoveRow = { [weak self] (row: Int) in
            RCLogO("Remove item at row \(row)")
            if row >= 0 {
                self?.presenter!.removeTask(at: row)
                self?.tasksScrollView!.removeTask(at: row)
            }
        }
        scrollView.didAddRow = { [weak self] (row: Int) -> Void in
            RCLogO("Add item after row \(row)")
            if row >= 0 {
                self?.rectToDisplayPopoverAt = scrollView.frameOfCell(atRow: row)
                self?.presenter!.insertTask(after: row)
            }
        }
        scrollView.didCloseDay = { [weak self] (tasks, shouldSaveToJira) -> Void in
            self?.presenter!.closeDay(shouldSaveToJira: shouldSaveToJira)
        }
        
        scrollView.reloadData()
        tasksScrollView = scrollView
    }
    
    func showReports (_ reports: [Report], numberOfDays: Int, type: ListType) {
        
        var frame = splitView.subviews[SplitViewColumn.tasks.rawValue].frame
        frame.origin = NSPoint.zero
        let scrollView = TasksScrollView(reports: reports, numberOfDays: numberOfDays, type: type)
        scrollView.frame = frame
        splitView!.subviews[SplitViewColumn.tasks.rawValue].addSubview(scrollView)
        scrollView.constrainToSuperview()
        scrollView.reloadData()
        scrollView.didChangeSettings = { [weak self] in
            if let strongSelf = self {
                strongSelf.handleSegmentedControl(strongSelf.listSegmentedControl)
            }
        }
        tasksScrollView = scrollView
    }
    
    func removeTasksController() {
        
        if tasksScrollView != nil {
            tasksScrollView?.removeFromSuperview()
            tasksScrollView = nil
        }
    }
    
    func selectDay (_ day: Day) {
        calendarScrollView.selectDay(day)
    }
    
    func presentNewTaskController (date: Date) {
        
        let popover = NSPopover()
        let controller = NewTaskViewController.instantiateFromStoryboard("Components")
        controller.onSave = { [weak self] (taskData: TaskCreationData) -> Void in
            if let strongSelf = self {
                strongSelf.presenter!.insertTaskWithData(taskData)
                strongSelf.presenter!.updateNoTasksState()
                strongSelf.presenter!.reloadData()
                popover.performClose(nil)
            }
        }
        controller.onCancel = { [weak self] in
            if let strongSelf = self {
                popover.performClose(nil)
                strongSelf.activePopover = nil
                strongSelf.presenter!.updateNoTasksState()
            }
        }
        popover.contentViewController = controller
        popover.show(relativeTo: rectToDisplayPopoverAt!, of: self.tasksScrollView!.view(), preferredEdge: NSRectEdge.maxY)
        // Add data after popover is presented
        controller.dateStart = nil// TODO Add scrum start date when around scrum date
        controller.dateEnd = date
        activePopover = popover
    }

    func presentEndDayController (date: Date, tasks: [Task]) {

        splitView.isHidden = true
        appWireframe!.removePlaceholder()
        hideControls(true)

        let controller = appWireframe!.presentEndDayController(date: date, tasks: tasks)
        controller.onSave = { [weak self] in
            if let strongSelf = self {
                strongSelf.appWireframe!.removeEndDayController()
                strongSelf.splitView.isHidden = false
                strongSelf.hideControls(false)
                strongSelf.presenter!.reloadData()
            }
        }
        controller.onCancel = { [weak self] in
            if let strongSelf = self {
                strongSelf.appWireframe!.removeEndDayController()
                strongSelf.splitView.isHidden = false
                strongSelf.hideControls(false)
                strongSelf.presenter!.updateNoTasksState()
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
