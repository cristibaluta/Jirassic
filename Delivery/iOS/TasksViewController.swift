//
//  DetailViewController.swift
//  Scrum
//
//  Created by Baluta Cristian on 05/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class TasksViewController: UITableViewController {

	var currentDay: Day?
	private var tasks = [Task]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		//		self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		//		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
		//		self.navigationItem.rightBarButtonItem = addButton
		
		self.title = currentDay!.dateStart.EEEEMMMMdd()
        
        let reader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
        tasks = reader.tasksInDay(currentDay!.dateStart)
        
        //        let reportInteractor = CreateReport()
        //        let reports = reportInteractor.reports(fromTasks: currentTasks, targetHoursInDay: nil)
        //        let currentReports = reports.reversed()
        //    }
        
		tableView.reloadData()
	}
	
	//	func insertNewObject(sender: AnyObject) {
	//		objects.insert(Date(), atIndex: 0)
	//		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
	//		self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	//	}
}

extension TasksViewController {
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableViewAutomaticDimension
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let theTask = tasks[indexPath.row]
//        RCLog(theData)
		
		if theTask.taskType == .issue || theTask.taskType == .gitCommit {
			let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
			cell.taskNrLabel!.text = theTask.taskNumber
            cell.dateLabel!.text = theTask.endDate.HHmm()
            cell.titleLabel!.text = (theTask.taskTitle ?? "").replacingOccurrences(of: "_", with: " ").replacingOccurrences(of: theTask.taskNumber!, with: "").trimmingCharacters(in: .whitespaces)
			cell.notesLabel!.text = theTask.notes?.trimmingCharacters(in: .whitespaces)
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "NonTaskCell", for: indexPath) as! NonTaskCell
            var notes = theTask.notes ?? theTask.taskType.defaultNotes
            if theTask.taskType == .coderev {
                notes = "\(theTask.taskType.defaultNotes): \(notes)"
            }
            if let startDate = theTask.startDate {
                cell.notesLabel!.text = "\(startDate.HHmm()) - \(theTask.endDate.HHmm()) \(notes)"
            } else {
                cell.notesLabel!.text = "\(theTask.endDate.HHmm()) \(notes)"
            }
			return cell
		}
	}
	
//	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//		// Return false if you do not want the specified item to be editable.
//		return true
//	}
//	
//	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//		if editingStyle == .delete {
//			tasks.remove(at: indexPath.row)
//			tableView.deleteRows(at: [indexPath], with: .fade)
//		} else if editingStyle == .insert {
//			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//		}
//	}
}

