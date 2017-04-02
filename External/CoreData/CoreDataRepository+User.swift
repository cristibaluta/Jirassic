//
//  CoreDataRepository+User.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataRepository: RepositoryUser {
    
    func currentUser() -> User {
        
        let userPredicate = NSPredicate(format: "isLoggedIn == YES")
        let cusers: [CUser] = queryWithPredicate(userPredicate, sortDescriptors: nil)
        if let cuser = cusers.last {
            return User(isLoggedIn: true, email: cuser.email, userId: cuser.userId, lastSyncDate: cuser.lastSyncDate)
        }
        
        return User(isLoggedIn: false, email: nil, userId: nil, lastSyncDate: nil)
    }
    
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        fatalError("This method is not applicable to CoreDataRepository")
    }
    
    func logout() {
        
        guard let context = managedObjectContext else {
            return
        }
        
        if #available(OSX 1000.11, *) {
            // TODO: This seems not to work under 10.11
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: CTask.self))
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try persistentStoreCoordinator()?.execute(deleteRequest, with: context)
            } catch let error as NSError {
                RCLog(error)
            }
        } else {
            let fetchRequest = NSFetchRequest<CTask>()
            fetchRequest.entity = NSEntityDescription.entity(forEntityName: String(describing: CTask.self), in: context)
            fetchRequest.includesPropertyValues = false
            do {
                let results = try context.fetch(fetchRequest)
                for result in results {
                    context.delete(result)
                }
                try context.save()
            } catch {
                
            }
        }
    }
}
