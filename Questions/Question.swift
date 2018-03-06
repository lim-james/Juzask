//
//  Question.swift
//  Questions
//
//  Created by James on 6/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Firebase

class Question {
    var room: Room
    var title: String = ""
    var admin: String = ""
    
    init(room: Room, title: String, admin: String) {
        self.room = room
        self.title = title
        self.admin = admin
    }
    
    init(under room: Room, from dict: [String: String]) {
        self.room = room
        self.title = dict["title"]!
        self.admin = dict["admin"]!
    }
    
    func create() {
        let ref: DatabaseReference = Database.database().reference()
        let value = [
            "title": title,
            "admin": admin,
        ]
        ref.child(room.code).childByAutoId().setValue(value)
    }
}
