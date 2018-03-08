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
    
    var source: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        
        ref = Database.database().reference()
        
        populate()
        
        title = room.title
        
        let askButton = UIButton()
        askButton.setTitle("ASK", for: .normal)
        askButton.setTitleColor(.white, for: .normal)
        askButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        askButton.backgroundColor = .blue
        askButton.sizeToFit()
        askButton.frame.size.width += 32
        askButton.layer.cornerRadius = 8
        askButton.clipsToBounds = true
        askButton.addTarget(self, action: #selector(self.askAction), for: .touchUpInside)
        
        let ask = UIBarButtonItem(customView: askButton)
        let code = UIBarButtonItem(title: room.code, style: .done, target: self, action: #selector(self.copyCode(_:)))
        
        navigationItem.rightBarButtonItems = [ask, code]
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
    }
    
    @objc func copyCode(_ sender: UIBarButtonItem) {
        UIPasteboard.general.string = room.code
        sender.title = "Copied!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sender.title = self.room.code
        }
        
    }
    
    func sort() {
        questions.sort(by: { (q1, q2) -> Bool in
            if q1.isAnswered { return false }
            if q2.isAnswered { return true }
            return q1.supporters.count > q2.supporters.count
        })
        searchedQuestions.sort { (q1, q2) -> Bool in
            if q1.isAnswered { return false }
            if q2.isAnswered { return true }
            return q1.supporters.count > q2.supporters.count
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
                self.source = "question"
                self.performSegue(withIdentifier: "showAnswer", sender: self)
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
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize * 2)
        label.textAlignment = .center
        label.textColor = .blue
        label.text = "No questions\nasked yet."
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return questions.count == 0 ? view.frame.height : 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let question = searching ? searchedQuestions[indexPath.row] : questions[indexPath.row]
        let qRef = ref.child(room.code).child(question.childId)
        source = ""
        if GIDSignIn.sharedInstance().currentUser != nil {
            let email = GIDSignIn.sharedInstance().currentUser.profile.email
            if room.adminEmail == email {
                source = "answer"
                performSegue(withIdentifier: "showAnswer", sender: self)
            } else {
                if question.isAnswered {
                    performSegue(withIdentifier: "showAnswer", sender: self)
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
        } else {
            if question.isAnswered {
                performSegue(withIdentifier: "showAnswer", sender: self)
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var question: Question!
            if searching {
                question = searchedQuestions[indexPath.row]
                searchedQuestions.remove(at: indexPath.row)
            } else {
                question = questions[indexPath.row]
                questions.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
            ref.child(room.code).child(question.childId).removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if GIDSignIn.sharedInstance().currentUser != nil {
            let email = GIDSignIn.sharedInstance().currentUser.profile.email
            if room.adminEmail == email { return .delete }
            let question = searching ? searchedQuestions[indexPath.row] : questions[indexPath.row]
            return question.adminEmail == email ? .delete : .none
        }
        return .none
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
            destination.title = source.isEmpty ? "Answer" : source.capitalized
            destination.source = source
            if source == "question" {
                let profile = GIDSignIn.sharedInstance().currentUser.profile
                destination.question = Question(room: room, title: "", admin: (profile?.name)!, adminEmail: (profile?.email)!)
            } else {
                let indexPath = tableView.indexPathForSelectedRow!
                let question = searching ? searchedQuestions[indexPath.row] : questions[indexPath.row]
                destination.question = question
            }
        }
    }
    
    @IBAction func unwindToQuestions(_ sender: UIStoryboardSegue) {}
    
}
