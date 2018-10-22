//
//  RepositoryInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

// Base class for any Interactor that wishes to use the repository
class RepositoryInteractor {
    
    var repository: Repository!
    var remoteRepository: Repository?
    
    init (repository: Repository, remoteRepository: Repository?) {
        self.repository = repository
        self.remoteRepository = remoteRepository
    }
}
