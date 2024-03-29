//
//  AnswersController.swift
//  Questions
//
//  Created by James on 7/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

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
        
        adminLabel.text = "by: " + question.admin
        adminLabel.font = UIFont.italicSystemFont(ofSize: adminLabel.font.pointSize)
        
        if question.answer.isEmpty {
            answerView.text = "Your " + source
            answerView.textColor = .lightGray
        } else {
            answerView.text = question.answer
            answerView.textColor = .blue
        }
        answerView.delegate = self
        answerView.font = UIFont.boldSystemFont(ofSize: (answerView.font?.pointSize)!)
        answerView.textContainerInset = UIEdgeInsets.zero
        answerView.textContainer.lineFragmentPadding = 0
        answerView.isScrollEnabled = false
        if GIDSignIn.sharedInstance().currentUser != nil {
            if question.isAnswered {
                answerView.isEditable = question.room.adminEmail == GIDSignIn.sharedInstance().currentUser.profile.email
            } else {
                answerView.isEditable = source == "question" || question.room.adminEmail == GIDSignIn.sharedInstance().currentUser.profile.email
            }
        } else {
            answerView.isEditable = false
        }
        
        if !source.isEmpty {
            let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneAction))
            navigationItem.rightBarButtonItem = button
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.toggleKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    
    @objc func toggleKeyboard() {
        if answerView.isFirstResponder {
            answerView.resignFirstResponder()
        } else {
            answerView.becomeFirstResponder()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.textColor = source == "question" ? .black : .blue
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
            answerView.textColor = source == "question" ? .black : .blue
        }
    }
    
    @objc func doneAction() {
        answerView.resignFirstResponder()
        if source == "question" {
            if answerView.text.exist() && answerView.textColor != .lightGray {
                question.title = answerView.text.chopped()
                question.create()
            }
            performSegue(withIdentifier: "unwindToQuestions", sender: self)
        } else if source == "answer" {
            if answerView.text.exist() && answerView.textColor != .lightGray {
                ref.child(question.room.code).child(question.childId).child("answer").setValue(answerView.text.chopped())
            }
            performSegue(withIdentifier: "unwindToQuestions", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            answerView.sizeToFit()
            return answerView.frame.height + 22
        case 1:
            return UITableViewAutomaticDimension
        default:
            return source == "question" ? 0 : UITableViewAutomaticDimension
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}
