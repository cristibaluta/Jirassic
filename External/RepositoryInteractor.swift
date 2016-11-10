//
//  RepositoryInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class RepositoryInteractor {
    
    var data: Repository!
    
    convenience init (data: Repository) {
        self.init()
        self.data = data
    }
}
