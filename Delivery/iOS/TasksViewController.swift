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
		
		self.title = self.currentDay!.date.EEEEMMdd()
		self.tasks = ReadDayInteractor(data: localRepository).tasksForDayOfDate(self.currentDay!.date)
		self.tableView.reloadData()
	}
	
	//	func insertNewObject(sender: AnyObject) {
	//		objects.insert(Date(), atIndex: 0)
	//		let indexPath = NSIndexPath(forRow: 0, inSection: 0)
	//		self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
	//	}
}

extension TasksViewController {
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return tasks.count
	}
	
	override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
		
		let theData = tasks[indexPath.row]
		
		if Int(theData.taskType!.intValue) == TaskType.Issue.rawValue {
			
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
		
		if Int(theData.taskType!.intValue) == TaskType.Issue.rawValue {
			let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell", forIndexPath: indexPath) as! TaskCell
			cell.taskNrLabel!.text = theData.issueId
			cell.dateLabel!.text = theData.endDate?.HHmm()
			cell.notesLabel!.text = theData.notes
			return cell
		}
		else {
			let cell = tableView.dequeueReusableCellWithIdentifier("NonTaskCell", forIndexPath: indexPath) as! NonTaskCell
			if Int(theData.taskType!.intValue) == TaskType.Start.rawValue {
				cell.circleWhite?.hidden = false
				cell.notesLabel!.text = theData.notes
			} else {
				cell.circleWhite?.hidden = true
				let thePreviousData = tasks[indexPath.row+1]
				cell.notesLabel!.text = "\(theData.notes!) \(thePreviousData.endDate!.HHmm()) - \(theData.endDate!.HHmm())"
			}
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

