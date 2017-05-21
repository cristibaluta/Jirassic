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
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
		let refreshControl = UIRefreshControl()
		refreshControl.tintColor = UIColor(red: 240.0/255, green: 40.0/255, blue: 40.0/255, alpha: 1.0)
		refreshControl.addTarget(self, action: #selector(DaysViewController.reloadData), for: .valueChanged)
		self.refreshControl = refreshControl
        
        UserDefaults.standard.serverChangeToken = nil
		reloadData()
	}
	
	func reloadData() {
        
//        let task = Task(dateEnd: Date(), type: .startDay)
//        localRepository.saveTask(task, completion: { (savedTask: Task) -> Void in
//            RCLog(savedTask)
//        })
        
        let interactor = ReadDaysInteractor(repository: localRepository)
        interactor.query { (weeks) in
            
            self.days = interactor.days()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
	}

	// MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTasksSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                //				(segue.destinationViewController as! TasksViewController).currentDay = days[indexPath.row]
            }
        }
    }
    
//    func reloadTasksOnDay (_ day: Day) {
//        
//        let reader = ReadTasksInteractor(repository: localRepository)
//        let currentTasks = reader.tasksInDay(day.date)
//        
//        let reportInteractor = CreateReport()
//        let reports = reportInteractor.reports(fromTasks: currentTasks, targetHoursInDay: nil)
//        let currentReports = reports.reversed()
//    }
}

extension DaysViewController {
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return days.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
		let object = days[indexPath.row]
		cell.textLabel!.text = object.date.EEEEMMdd()
		return cell
	}
}
