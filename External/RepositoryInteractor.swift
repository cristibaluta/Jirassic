//
//  RepositoryInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class RepositoryInteractor {
    
    var repository: Repository!
    
    convenience init (repository: Repository) {
        self.init()
        self.repository = repository
    }
}
