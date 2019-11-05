//
//  JiraRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/07/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import RCHttp

class JiraRepository {
    
    var request: RCHttp?
    var user: String!
    
    init (url: String, user: String, password: String) {
        
        self.user = user
        self.request = RCHttp(baseURL: url)
        self.request?.authenticate(user: user, password: password)
    }
}
