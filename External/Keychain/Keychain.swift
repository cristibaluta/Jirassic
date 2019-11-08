//
//  Keychain.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/03/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class Keychain {
    
    private static let key = "jira_password"
    
    class func getPassword() -> String {
        return KeychainWrapper.standard.string(forKey: key) ?? ""
    }
    
    class func setPassword(_ password: String?) {
        if let password = password {
            _ = KeychainWrapper.standard.set(password, forKey: key)
        } else {
            KeychainWrapper.standard.removeObject(forKey: key)
        }
    }
}
