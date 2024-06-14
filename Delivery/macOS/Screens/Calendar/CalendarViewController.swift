//
//  CalendarViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa

class CalendarViewController: NSViewController {
    
    @IBOutlet var monthTextField: NSTextField!
    
    weak var appWireframe: AppWireframe?
    var presenter: CalendarPresenterInput?
    
    var cells: [CalendarDayCellView] = []
    
    var didChangeDay: ((_ day: Day) -> Void)?
    var didChangeMonth: ((_ date: Date) -> Void)?
    
    private var day: Day? = Day(dateStart: Date().startOfDay(), dateEnd: nil)
    var selectedDay: Day? {
        get {
            return day
        }
        set {
            day = newValue
            if let d = day {
                selectCell(day: d)
            }
        }
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        reloadData()
    }
    
    func reloadData() {
        presenter!.reloadData()
        didChangeDay?(day!)
    }
    
    private func selectCell (day: Day) {
        for cell in cells {
            cell.isSelected = cell.day == day.dateStart.day()
        }
    }
    
    @IBAction func handlePrevMonth (_ sender: NSButton) {
        presenter!.goPrevMonth()
        didChangeMonth?(presenter!.selectedMonth)
    }
    
    @IBAction func handleNextMonth (_ sender: NSButton) {
        presenter!.goNextMonth()
        didChangeMonth?(presenter!.selectedMonth)
    }
}

extension CalendarViewController: CalendarPresenterOutput {
    
    func addCell (at index: Int, day: Day, isStarted: Bool) {
        let w = 20
        let y = 4
        
        let cell = CalendarDayCellView(frame: NSRect(x: index*w, y: y, width: w, height: w+w+6))
        cell.day = day.dateStart.day()
        cell.weekday = "\(day.dateStart.E())"
        cell.isSelected = day.dateStart.isSameDayAs(selectedDay?.dateStart ?? Date())
        cell.isStarted = isStarted
        cell.isEnded = day.dateEnd != nil
        cell.isToday = day.dateStart.isToday()
        cell.onClick = {
            self.selectCell(day: day)
            self.didChangeDay?(day)
        }
        self.view.addSubview(cell)
        cells.append(cell)
    }
    
    func clearCells() {
        for cell in cells {
            cell.removeFromSuperview()
        }
        cells = []
    }
    
    func showMonthName (_ name: String) {
        monthTextField.stringValue = name
    }
}
