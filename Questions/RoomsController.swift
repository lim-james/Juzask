//
//  ViewController.swift
//  Questions
//
//  Created by James on 3/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Firebase

class RoomsController: UITableViewController, UISearchResultsUpdating {
    
    var ref: DatabaseReference!
    
    var roomIds: [String] = []
    var rooms: [Room] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        populate()
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        }
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
    }
    
    func populate() {
        if let ids = UserDefaults.standard.array(forKey: "Room Codes") {
            roomIds = ids as! [String]
        }
        for id in roomIds {
            ref.child("Rooms").observe(.value, with: { snap in
                if snap.hasChild(id) {
                    self.ref.child("Rooms").child(id).observe(.value) { snapshot in
                        let dict = snapshot.value as! [String: String]
                        let room = Room(from: dict)
                        if !self.rooms.contains(where: { (r) -> Bool in
                            return r.code == room.code
                        }) {
                            self.rooms.append(room)
                        }
                        self.reload()
                    }
                } else {
                    if !self.rooms.contains(where: { (r) -> Bool in
                        return r.code == id
                    }) {
                        self.rooms.append(Room(title: "Room does not exist", admin: "Swipe right to delete", code: id))
                        self.reload()
                    }
                }
            })
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    @objc func joinAction() {
        let alertController = UIAlertController(title: "Enter ID", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Join", style: .default) { (_) in
            let field = alertController.textFields![0]
            if !self.roomIds.contains(field.text!) && !(field.text?.isEmpty)! {
                self.roomIds.append(field.text!)
                UserDefaults.standard.set(self.roomIds, forKey: "Room Codes")
                self.populate()
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
    
    @IBAction func addRoomAction(_ sender: Any) {
        let alertController = UIAlertController(title: "Enter room title", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Create", style: .default) { (_) in
            let field = alertController.textFields![0]
            if !(field.text?.isEmpty)! {
                let room = Room(title: field.text!, admin: "admin")
                self.roomIds.append(room.code)
                UserDefaults.standard.set(self.roomIds, forKey: "Room Codes")
                room.create()
                self.populate()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuestions" {
            let destination = segue.destination as! QuestionsController
            destination.room = rooms[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.25) {
            cell.alpha = 1
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let joinButton = UIButton()
        
        joinButton.setTitle("Join room", for: .normal)
        joinButton.backgroundColor = view.tintColor
        joinButton.addTarget(self, action: #selector(self.joinAction), for: .touchUpInside)
        
        return joinButton
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RoomsCell
        
        cell.session = rooms[indexPath.row]
        
        return cell
    }
}

