//
//  Session.swift
//  Questions
//
//  Created by James on 3/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

class Session {
    var title: String
    var admin: String
    var code: String
    
    init() {
        title = ""
        admin = ""
        code = ""
    }
    
    init(title: String, admin: String, code: String) {
        self.title = title
        self.admin = admin
        self.code = code
    }
}
