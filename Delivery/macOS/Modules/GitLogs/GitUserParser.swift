//
//  GitUserParser.swift
//  Jirassic
//
//  Created by Cristian Baluta on 14/12/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class GitUserParser {
    
    private var raw: String

    init (raw: String) {
        self.raw = raw
    }

    func toGitUsers() -> [GitUser] {

        var users = [GitUser]()

        let r = raw.replacingOccurrences(of: "\r", with: "\n")
        let results = r.split(separator: "\n").map { String($0) }
        for result in results {
            if let user = parseUser(result) {
                users.append(user)
            }
        }

        return users
    }

    private func parseUser (_ user: String) -> GitUser? {

        var comps = user.split(separator: ";").map { String($0) }
        guard comps.count >= 2 else {
            return nil
        }
        let name = comps.removeFirst()
        let email = comps.removeFirst()

        return GitUser(name: name, email: email)
    }
}
