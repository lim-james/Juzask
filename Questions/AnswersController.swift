//
//  AnswersController.swift
//  Questions
//
//  Created by James on 7/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Firebase

class AnswersController: UITableViewController, UITextViewDelegate {

    var ref: DatabaseReference!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var answerView: UITextView!
    
    var source: String!
    var question: Question!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        
        titleLabel.text = question.title
        
        adminLabel.text = question.admin
        adminLabel.font = UIFont.italicSystemFont(ofSize: adminLabel.font.pointSize)
        
        if question.answer.isEmpty {
            answerView.text = "Your " + source
            answerView.textColor = .lightGray
        } else {
            answerView.text = question.answer
            answerView.textColor = .green
        }
        answerView.delegate = self
        answerView.font = UIFont.boldSystemFont(ofSize: (answerView.font?.pointSize)!)
        answerView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        answerView.isScrollEnabled = false
        
        if !source.isEmpty {
            let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneAction))
            navigationItem.rightBarButtonItem = button
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.textColor = source == "question" ? .black : .green
            textView.text = ""
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if answerView.text.isEmpty {
            answerView.text = "Your " + source
            answerView.textColor = .lightGray
        } else {
            answerView.textColor = source == "question" ? .black : .green
        }
    }
    
    @objc func doneAction() {
        answerView.resignFirstResponder()
        if !answerView.text.isEmpty && answerView.textColor != .lightGray {
            if source == "question" {
                question.title = answerView.text
                question.create()
                performSegue(withIdentifier: "unwindToQuestions", sender: self)
            } else if source == "answer" {
                ref.child(question.room.code).child(question.childId).child("answer").setValue(answerView.text)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            answerView.sizeToFit()
            return answerView.frame.height + 22
        default:
            return source == "question" ? 0 : UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}
