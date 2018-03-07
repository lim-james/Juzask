//
//  QuestionsController.swift
//  Questions
//
//  Created by James on 6/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class QuestionsController: UITableViewController, UISearchResultsUpdating, GIDSignInUIDelegate {
    
    var ref: DatabaseReference!
    
    var room: Room!
    var questions: [Question] = []
    var searchedQuestions: [Question] = []
    
    var searching: Bool! {
        return searchController.isActive
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        ref = Database.database().reference()
        
        populate()
        
        title = room.title
        navigationItem.prompt = room.admin
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
    }
    
    func sort() {
        questions.sort(by: { (q1, q2) -> Bool in
            return !q1.isAnswered || q1.supporters.count > q2.supporters.count
        })
        searchedQuestions.sort { (q1, q2) -> Bool in
            return !q1.isAnswered || q1.supporters.count > q2.supporters.count
        }
    }
    
    func filterSearch() {
        let text = searchController.searchBar.text!
        searchedQuestions = questions.filter { (question) -> Bool in
            return question.title.contains(text) || question.admin.contains(text)
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterSearch()
        reload()
    }
    
    func populate() {
        ref.child(room.code).observe(.value, with: { snapshot in
            self.questions.removeAll()
            for child in snapshot.children {
                let data = child as! DataSnapshot
                let dict = data.value as! [String: Any]
                let question = Question(under: self.room, from: dict, childId: data.key)
                self.questions.append(question)
                self.filterSearch()
                self.sort()
                self.reload()
            }
        })
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func askAction() {
        if searching { searchController.isActive = false }
        DispatchQueue.main.async {
            if GIDSignIn.sharedInstance().currentUser != nil {
                let alertController = UIAlertController(title: "Enter question", message: nil, preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Ask", style: .default) { (_) in
                    let field = alertController.textFields![0]
                    if !(field.text?.isEmpty)! {
                        let profile = GIDSignIn.sharedInstance().currentUser.profile
                        Question(room: self.room, title: field.text!, admin: (profile?.name)!, adminEmail: (profile?.email)!).create()
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addTextField { textField in
                    textField.textAlignment = .center
                    textField.returnKeyType = .done
                    textField.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: "Log in to continue", message: nil, preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Ok", style: .default) { (_) in
                    GIDSignIn.sharedInstance().signIn()
                }
                
                let cancelAction = UIAlertAction(title: "Nope", style: .cancel, handler: nil)
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = searching ? searchedQuestions[indexPath.row] : questions[indexPath.row]
        let qRef = ref.child(room.code).child(question.childId)
        if question.isAnswered {
            performSegue(withIdentifier: "showAnswer", sender: self)
        } else {
            let email = GIDSignIn.sharedInstance().currentUser.profile.email
            if question.adminEmail == email {
                let alertController = UIAlertController(title: question.title, message: nil, preferredStyle: .alert)
                
                let confirmAction = UIAlertAction(title: "Answer", style: .default) { (_) in
                    let field = alertController.textFields![0]
                    if !(field.text?.isEmpty)! {
                        qRef.child("answer").setValue(field.text)
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alertController.addTextField { textField in
                    textField.placeholder = "Your answer"
                    textField.textAlignment = .center
                    textField.returnKeyType = .done
                    textField.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
                }
                
                alertController.addAction(confirmAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
            } else {
                var key = ""
                if question.supporters.contains(where: { (k, v) -> Bool in
                    if v == email {
                        key = k
                        return true
                    }
                    return false
                })  {
                    qRef.child("supporters").child(key).removeValue()
                } else {
                    qRef.child("supporters").childByAutoId().setValue(email)
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let question = searching ? searchedQuestions[indexPath.row] : questions[indexPath.row]
            ref.child(room.code).child(question.childId).removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let email = GIDSignIn.sharedInstance().currentUser.profile.email
        if room.adminEmail == email { return .delete }
        let question = searching ? searchedQuestions[indexPath.row] : questions[indexPath.row]
        return question.adminEmail == email ? .delete : .none
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let askButton = UIButton()
        
        askButton.setTitle("Ask question", for: .normal)
        askButton.backgroundColor = .green
        askButton.addTarget(self, action: #selector(self.askAction), for: .touchUpInside)
        
        return askButton
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searching ? searchedQuestions.count : questions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! QuestionsCell
        
        cell.question = searching ? searchedQuestions[indexPath.row] : questions[indexPath.row]
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAnswer" {
            let destination = segue.destination as! AnswersController
            let indexPath = tableView.indexPathForSelectedRow!
            let question = searching ? searchedQuestions[indexPath.row] : questions[indexPath.row]
            destination.title = "Answer"
            destination.question = question
        }
    }
    
}
