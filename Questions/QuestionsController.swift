//
//  QuestionsController.swift
//  Questions
//
//  Created by James on 6/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Firebase

class QuestionsController: UITableViewController, UISearchResultsUpdating {
    
    var ref: DatabaseReference!
    
    var room: Room!
    var questions: [Question] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func populate() {
        ref.child(room.code).observe(.value, with: { snapshot in
            self.questions.removeAll()
            for child in snapshot.children {
                let data = child as! DataSnapshot
                let dict = data.value as! [String: String]
                let question = Question(under: self.room, from: dict)
                self.questions.append(question)
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
        let alertController = UIAlertController(title: "Enter question", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Ask", style: .default) { (_) in
            let field = alertController.textFields![0]
            if !(field.text?.isEmpty)! {
                Question(room: self.room, title: field.text!, admin: "James").create()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { (textField) in
            textField.textAlignment = .center
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.25) {
            cell.alpha = 1
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let askButton = UIButton()
        
        askButton.setTitle("Ask question", for: .normal)
        askButton.backgroundColor = view.tintColor
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
        return questions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! QuestionsCell
        
        cell.question = questions[indexPath.row]
        
        return cell
    }

}
