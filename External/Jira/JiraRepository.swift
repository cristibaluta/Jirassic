//
//  JiraRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/07/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

class JiraRepository {
    
    var url: String
    var user: String
    var password: String
    var request: RCHttp?
    
    init (url: String, user: String, password: String) {
        self.url = url
        self.user = user
        self.password = password
        self.request = RCHttp()
        self.request?.authenticate(user: user, password: password)
    }
}
