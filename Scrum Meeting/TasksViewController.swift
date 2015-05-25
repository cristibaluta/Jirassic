//
//  DetailViewController.swift
//  Scrum
//
//  Created by Baluta Cristian on 05/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class TasksViewController: UITableViewController {

	var currentDay: Task?
	var tasks = [Task]()
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		//		self.navigationItem.leftBarButtonItem = self.editButtonItem()
		
		//		let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
		//		self.navigationItem.rightBarButtonItem = addButton
		
		self.title = self.currentDay!.date_task_finished?.EEEEMMdd()
		self.tasks = sharedData.tasksForDayOnDate(self.currentDay!.date_task_finished!)
		self.tableView.reloadData()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	//	func insertNewObject(sender: AnyObject) {
	//		objects.insert(NSDate(), atIndex: 0)
	//		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
	//		self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	//	}
}

extension TasksViewController: UITableViewDataSource, UITableViewDelegate {
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		let theData = tasks[indexPath.row]
		
		if Int(theData.task_type!.intValue) == TaskType.Issue.rawValue {
			
			return NSString(string: theData.notes!).boundingRectWithSize(
				CGSize(width: self.view.frame.size.width - 48, height: 999),
				options: NSStringDrawingOptions.UsesLineFragmentOrigin,
				attributes: [NSFontAttributeName: UIFont.systemFontOfSize(17)],
				context: nil).size.height + 56
		} else {
			return 50
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let theData = tasks[indexPath.row]
		
		if Int(theData.task_type!.intValue) == TaskType.Issue.rawValue {
			let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskCell
			cell.taskNrLabel!.text = theData.task_nr
			cell.dateLabel!.text = theData.date_task_finished?.HHmm()
			cell.notesLabel!.text = theData.notes
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("NonTaskCell", forIndexPath: indexPath) as! NonTaskCell
//			cell.dateLabel!.text = theData.date_task_finished?.HHmm()
			cell.notesLabel!.text = theData.notes
			return cell
		}
	}
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			tasks.removeAtIndex(indexPath.row)
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
		} else if editingStyle == .Insert {
			// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
		}
	}
}

