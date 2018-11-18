//
//  MasterViewController.swift
//  Scrum
//
//  Created by Baluta Cristian on 05/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import UIKit

class DaysViewController: UITableViewController {

	var weeks = [Week]()
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
		let refreshControl = UIRefreshControl()
        refreshControl.tintColor = appRed
		refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
		self.refreshControl = refreshControl
        
		reloadData()
	}
	
    @objc func reloadData() {
        
        let interactor = ReadDaysInteractor(repository: localRepository, remoteRepository: remoteRepository)
        interactor.queryAll { weeks in
            
            self.weeks = weeks
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
                (segue.destination as! TasksViewController).currentDay = weeks[indexPath.section].days[indexPath.row]
            }
        }
    }
}

extension DaysViewController {
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return weeks.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return weeks[section].date.weekInterval()
    }
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return weeks[section].days.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
		let day = weeks[indexPath.section].days[indexPath.row]
		cell.textLabel!.text = day.dateStart.EEEEMMMMdd()
		return cell
	}
}
