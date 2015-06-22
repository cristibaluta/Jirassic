//
//  UserProtocol.swift
//  Jirassic
//
//  Created by Baluta Cristian on 14/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

protocol JRUserProtocol: NSObjectProtocol {

	var isLoggedIn: Bool {get}
	var password: String? {get set}
	var email: String? {get set}
}
