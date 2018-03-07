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
    var title: String
    var admin: String
    var adminEmail: String
    var childId: String
    var supporters: [String: String]
    var answer: String
    
    var isAnswered: Bool {
        return !answer.isEmpty
    }
    
    init(room: Room, title: String, admin: String, adminEmail: String) {
        self.room = room
        self.title = title
        self.admin = admin
        self.adminEmail = adminEmail
        self.childId = ""
        self.supporters = [:]
        self.answer = ""
    }
    
    init(under room: Room, from dict: [String: Any], childId: String) {
        self.room = room
        self.title = dict["title"] as! String
        self.admin = dict["admin"] as! String
        self.adminEmail = dict["adminEmail"] as! String
        self.childId = childId
        if dict["supporters"] != nil {
            self.supporters = dict["supporters"] as! [String: String]
        } else {
            self.supporters = [:]
        }
        self.answer = dict["answer"] as! String
    }
    
    func create() {
        let ref: DatabaseReference = Database.database().reference()
        let value = [
            "title": title,
            "admin": admin,
            "adminEmail": adminEmail,
            "answer": answer
            ] as [String : String]
        let postRef = ref.child(room.code).childByAutoId()
        postRef.setValue(value)
    }
}
