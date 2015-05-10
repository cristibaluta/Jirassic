//
//  MasterViewController.swift
//  Scrum
//
//  Created by Baluta Cristian on 05/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class DaysViewController: UITableViewController {

	var days = [Task]()


	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		sharedData.queryData { (tasks, error) -> Void in
			self.days = sharedData.days()
			self.tableView.reloadData()
		}
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "ShowTasksSegue" {
		    if let indexPath = self.tableView.indexPathForSelectedRow() {
		        let object = days[indexPath.row]
		    (segue.destinationViewController as! TasksViewController).currentDay = object
		    }
		}
	}

	// MARK: - Table View

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return days.count
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath) as! UITableViewCell

		let object = days[indexPath.row]
		cell.textLabel!.text = object.date_task_finished?.EEEEMMdd()
		return cell
	}

}

