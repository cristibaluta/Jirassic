//
//  User.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

struct User {

	var isLoggedIn: Bool
	var email: String?
    var userId: String?
}

typealias UserCredentials = (email: String, password: String)
