//
//  ReadUserInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 03/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadUserInteractor {
    
    func execute() -> User {
        return remoteRepository.currentUser()
    }
}
