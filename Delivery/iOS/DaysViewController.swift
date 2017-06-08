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
        refreshControl.tintColor = appRed
		refreshControl.addTarget(self, action: #selector(DaysViewController.reloadData), for: .valueChanged)
		self.refreshControl = refreshControl
        
		reloadData()
	}
	
	func reloadData() {
        
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
                (segue.destination as! TasksViewController).currentDay = days[indexPath.row]
            }
        }
    }
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
