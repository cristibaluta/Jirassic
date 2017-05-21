//
//  CUser.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CoreData


class CUser: NSManagedObject {
    
    @NSManaged var userId: String?
    @NSManaged var email: String?

}
