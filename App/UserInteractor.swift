//
//  UserInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 03/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class UserInteractor {
    
    func currentUser() -> User {
        return remoteRepository.currentUser()
    }
    
}
