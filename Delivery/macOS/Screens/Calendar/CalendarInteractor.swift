//
//  CalendarInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Foundation
import RCLog

protocol CalendarInteractorInput: class {
    
    func loadCalendar(date: Date)
}

protocol CalendarInteractorOutput: class {
    
    func calendarDidLoad (_ weeks: [Week])
}

class CalendarInteractor {
    
    weak var presenter: CalendarInteractorOutput?
    private let daysReader: ReadDaysInteractor!
    
    init() {
        daysReader = ReadDaysInteractor(repository: localRepository, remoteRepository: remoteRepository)
    }
}

extension CalendarInteractor: CalendarInteractorInput {
    
    func loadCalendar(date: Date) {

        daysReader.query(startingDate: date.startOfMonth(), endingDate: date.endOfMonth()) { [weak self] weeks in
            self?.presenter?.calendarDidLoad(weeks)
        }
    }
    
}
