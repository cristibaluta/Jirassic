//
//  MasterViewController.swift
//  Scrum
//
//  Created by Baluta Cristian on 05/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class DaysViewController: UITableViewController {

	var days = [Day]()
	
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = UIColor(red: 240.0/255, green: 40.0/255, blue: 40.0/255, alpha: 1.0)
		refreshControl.addTarget(self, action: Selector("reloadData"), forControlEvents: .ValueChanged)
		self.refreshControl = refreshControl
		reloadData()
	}
	
	func reloadData() {
		localRepository.queryTasks { (tasks, error) -> Void in
			self.days = ReadDaysInteractor(dataManager: localRepository).days()
			self.tableView.reloadData()
			self.refreshControl?.endRefreshing()
		}
	}

	// MARK: - Segues

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "ShowTasksSegue" {
		    if let indexPath = self.tableView.indexPathForSelectedRow {
				(segue.destinationViewController as! TasksViewController).currentDay = days[indexPath.row]
		    }
		}
	}
}

extension DaysViewController {
	
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return days.count
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("DayCell", forIndexPath: indexPath)
		let object = days[indexPath.row]
		cell.textLabel!.text = object.date.EEEEMMdd()
		return cell
	}
}
