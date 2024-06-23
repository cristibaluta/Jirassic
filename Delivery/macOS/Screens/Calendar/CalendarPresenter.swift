//
//  CalendarPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Foundation

protocol CalendarPresenterInput: class {
    func reloadData()
    func goPrevMonth()
    func goNextMonth()
    var selectedMonth: Date { get }
}

protocol CalendarPresenterOutput: class {
    func addCell (at index: Int, day: Day, isStarted: Bool)
    func clearCells()
    func showMonthName (_ name: String)
}

class CalendarPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: CalendarPresenterOutput?
    var interactor: CalendarInteractorInput?
    var selectedMonth: Date = Date() {
        didSet {
            reloadData()
        }
    }
}

extension CalendarPresenter: CalendarPresenterInput {
    
    func reloadData() {
        ui!.showMonthName(selectedMonth.MMMyyyy())
        ui!.clearCells()
        interactor!.loadCalendar(date: selectedMonth)
    }
    
    func goPrevMonth() {
        selectedMonth = selectedMonth.dateByAddingMonths(-1)
    }
    
    func goNextMonth() {
        selectedMonth = selectedMonth.dateByAddingMonths(1)
    }
}

extension CalendarPresenter: CalendarInteractorOutput {
    
    func calendarDidLoad(_ weeks: [Week]) {
        DispatchQueue.main.async {
            let existingDays = weeks.flatMap({$0.days})
            let firstDate = existingDays.first?.dateStart ?? self.selectedMonth
            var days = [(Day, Bool)]()
            for i in 1...firstDate.daysInMonth() {
                if let day = existingDays.filter({$0.dateStart.day() == i}).first {
                    days.append((day, true))
                } else {
                    let day = Day(dateStart: firstDate.dateByUpdating(day: i), dateEnd: nil)
                    days.append((day, false))
                }
            }
            var i = 0
            var isWeekend = false
            for day in days {
                if day.0.dateStart.day() == 1 && day.0.dateStart.isWeekend() {
                    isWeekend = false
                    continue
                }
                if isWeekend && day.0.dateStart.isWeekend() {
                    isWeekend = false
                    continue
                }
                if day.0.dateStart.isWeekend() && !day.0.dateStart.isToday() {
                    i += 1
                    isWeekend = true
                } else {
                    self.ui!.addCell(at: i, day: day.0, isStarted: day.1)
                    i += 1
                }
            }
        }
    }
}
