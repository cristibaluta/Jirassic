//
//  TasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import RCLog

class TasksViewController: NSViewController {

    @IBOutlet private var loadingTasksIndicator: NSProgressIndicator!
    private var tasksScrollView: TasksScrollView?
    private var worklogsViewController: WorklogsViewController?
    /// Property to keep a reference to the active cell rect
    private var activeCellRect: NSRect?
    private var activePopover: NSPopover?

    weak var appWireframe: AppWireframe?
    var presenter: TasksPresenterInput?

    deinit {
        RCLog(self)
    }
}

extension TasksViewController: TasksPresenterOutput {

    func showLoadingIndicator (_ show: Bool) {

        if show {
            loadingTasksIndicator.isHidden = false
            loadingTasksIndicator.startAnimation(nil)
        } else {
            loadingTasksIndicator.stopAnimation(nil)
            loadingTasksIndicator.isHidden = true
        }
    }

    func showMessage (_ message: MessageViewModel) {

        let controller = appWireframe!.presentPlaceholder(message, in: self.view)
        controller.didPressButton = {
            self.presenter?.didClickStartDay()
        }
    }

    func showTasks (_ tasks: [Task]) {

        let dataSource = TasksDataSource(tasks: tasks)
        dataSource.didClickAddRow = { [weak self] row in
            RCLogO("Click add item after row \(row)")
            if row >= 0 {
                self?.activeCellRect = self?.tasksScrollView?.frameOfCell(atRow: row)
                self?.presenter!.insertTask(after: row)
            }
        }
        dataSource.didClickRemoveRow = { [weak self] row in
            RCLogO("Click remove item at row \(row)")
            if row >= 0 {
                self?.presenter!.removeTask(at: row)
                self?.tasksScrollView!.removeTask(at: row)
                self?.tasksScrollView!.reloadFooter()
            }
        }
        dataSource.didClickEditRow = { [weak self] row in
            RCLogO("Click edit item at row \(row)")
            if row >= 0 {
                self?.activeCellRect = self?.tasksScrollView?.frameOfCell(atRow: row)
                self?.presenter!.editTask(at: row)
            }
        }
        dataSource.didClickCloseDay = { [weak self] tasks in
            self?.presenter!.closeDay(showWorklogs: true)
        }
        dataSource.didClickSaveWorklogs = { [weak self] in
            self?.presenter!.didClickSaveWorklogs()
        }
        dataSource.didClickSetupJira = { [weak self] in
            self?.appWireframe!.flipToSettingsController()
        }

        let scrollView = TasksScrollView(dataSource: dataSource)
        self.view.addSubview(scrollView)
        scrollView.constrainToSuperview()

        scrollView.reloadData()
        tasksScrollView = scrollView
    }

    func removeTasks() {

        if tasksScrollView != nil {
            tasksScrollView?.removeFromSuperview()
            tasksScrollView = nil
        }
    }

    func presentNewTaskController (date: Date) {

        let popover = NSPopover()
        let controller = NewTaskViewController.instantiateFromStoryboard("Tasks")
        controller.onSave = { [weak self] taskData in
            self?.presenter!.saveNewTask(with: taskData)
            self?.presenter!.updateNoTasksState()
            self?.presenter!.reloadLastSelectedDay()
            self?.closeTaskEditor()
        }
        controller.onCancel = { [weak self] in
            self?.closeTaskEditor()
            self?.presenter!.updateNoTasksState()
        }
        popover.contentViewController = controller
        var rect = activeCellRect!
        rect.origin.y = self.view.frame.height - rect.origin.y - rect.height
        popover.show(relativeTo: rect, of: self.view, preferredEdge: NSRectEdge.maxY)
        // Add data after popover is presented
        controller.dateStart = nil// TODO Add scrum start date when around scrum date
        controller.dateEnd = date
        activePopover = popover
    }

    func presentTaskEditor (task: Task) {

        let popover = NSPopover()
        let controller = NewTaskViewController.instantiateFromStoryboard("Tasks")
        controller.onSave = { [weak self] taskCreationData in
            self?.presenter!.updateTask(task, with: taskCreationData)
            self?.presenter!.reloadLastSelectedDay()
            self?.closeTaskEditor()
        }
        controller.onCancel = { [weak self] in
            self?.closeTaskEditor()
            self?.presenter!.updateNoTasksState()
        }
        popover.contentViewController = controller
        var rect = activeCellRect!
        rect.origin.y = self.view.frame.height - rect.origin.y - rect.height/2
        popover.show(relativeTo: rect, of: self.view, preferredEdge: NSRectEdge.maxY)
        activePopover = popover

        controller.notes = task.notes
        controller.taskNumber = task.taskNumber
        controller.dateStart = task.startDate
        controller.dateEnd = task.endDate
        controller.taskType = task.taskType
        controller.projectId = task.projectId
    }

    func closeTaskEditor() {
        activePopover?.contentViewController = nil
        activePopover?.performClose(nil)
        activePopover = nil
    }

    func showWorklogs (date: Date, tasks: [Task]) {

        let controller = appWireframe!.createWorklogsViewController()
        controller.date = date
        controller.tasks = tasks
        self.view.addSubview(controller.view)
        controller.view.constrainToSuperview()
        controller.onSave = { [weak self] in
            self?.presenter!.reloadLastSelectedDay()
        }
        controller.onCancel = { [weak self] in
            self?.presenter!.reloadLastSelectedDay()
        }
        worklogsViewController = controller
    }

    func removeWorklogs() {

        if worklogsViewController != nil {
            worklogsViewController?.removeFromSuperview()
            worklogsViewController = nil
        }
    }
}
