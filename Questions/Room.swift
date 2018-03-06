//
//  Session.swift
//  Questions
//
//  Created by James on 3/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Firebase

class Room {
    var title: String = ""
    var admin: String = ""
    var code: String = ""
    
    init(title: String, admin: String) {
        self.title = title
        self.admin = admin
        self.code = getCode()
    }
    
    init(title: String, admin: String, code: String) {
        self.title = title
        self.admin = admin
        self.code = code
    }
    
    init(from dict: [String: String]) {
        self.title = dict["title"]!
        self.admin = dict["admin"]!
        self.code = dict["code"]!
    }
    
    func create() {
        let ref: DatabaseReference = Database.database().reference()
        let value = [
            "title": title,
            "admin": admin,
            "code": code
        ]
        ref.child("Rooms").child(code).setValue(value)
    }
    
    func getCode() -> String {
        let items = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var list: [String] = []
        for i in items { list.append(String(i)) }
        var str = ""
        for _ in 0...3 {
            str = str + list[Int(arc4random_uniform(UInt32(list.count)))]
        }
        return str
    }
}
