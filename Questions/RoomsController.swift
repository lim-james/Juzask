//
//  ViewController.swift
//  Questions
//
//  Created by James on 3/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class RoomsController: UITableViewController, UISearchResultsUpdating, GIDSignInUIDelegate {
    
    var ref: DatabaseReference!
    
    var roomCodes: [String] = []
    var rooms: [Room] = []
    var searchedRooms: [Room] = []
    
    var searching: Bool! {
        return searchController.isActive
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
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
            roomCodes = ids as! [String]
        }
        ref.child("Rooms").observe(.value, with: { snap in
            for code in self.roomCodes {
                if snap.hasChild(code) {
                    self.ref.child("Rooms").child(code).observe(.value) { snapshot in
                        let dict = snapshot.value as! [String: String]
                        let room = Room(from: dict)
                        if !self.rooms.contains(where: { (r) -> Bool in
                            return r.code == room.code
                        }) {
                            self.rooms.append(room)
                            self.reload()
                        }
                    }
                } else {
                    if !self.rooms.contains(where: { (r) -> Bool in
                        return r.code == code
                    }) {
                        self.rooms.append(Room(title: "Room does not exist", admin: "Swipe right to delete", adminEmail: "", code: code))
                        self.reload()
                    }
                }
            }
        })
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func update() {
        UserDefaults.standard.set(roomCodes, forKey: "Room Codes")
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
        searchedRooms = rooms.filter { (room) -> Bool in
            return room.title.contains(text) || room.admin.contains(text) || room.code.contains(text)
        }
        reload()
    }
    
    @IBAction func editAction(_ sender: Any) {
        if tableView.isEditing {
            editButton.title = "Edit"
            tableView.setEditing(false, animated: true)
        } else {
            editButton.title = "Done"
            tableView.setEditing(true, animated: true)
        }
    }
    
    @objc func joinAction() {
        if searching { searchController.isActive = false }
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Enter ID", message: nil, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Join", style: .default) { (_) in
                let field = alertController.textFields![0]
                if !self.roomCodes.contains(field.text!) && !(field.text?.isEmpty)! {
                    self.roomCodes.append(field.text!)
                    UserDefaults.standard.set(self.roomCodes, forKey: "Room Codes")
                    self.populate()
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
        }
    }
    
    @IBAction func addRoomAction(_ sender: Any) {
        if GIDSignIn.sharedInstance().currentUser != nil {
            let alertController = UIAlertController(title: "Enter room title", message: nil, preferredStyle: .alert)
            
            let confirmAction = UIAlertAction(title: "Create", style: .default) { (_) in
                let field = alertController.textFields![0]
                if !(field.text?.isEmpty)! {
                    let profile = GIDSignIn.sharedInstance().currentUser.profile
                    let room = Room(title: field.text!, admin: (profile?.name)!, adminEmail: (profile?.email)!)
                    self.roomCodes.append(room.code)
                    UserDefaults.standard.set(self.roomCodes, forKey: "Room Codes")
                    room.create()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuestions" {
            let destination = segue.destination as! QuestionsController
            destination.room = rooms[(tableView.indexPathForSelectedRow?.row)!]
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let room = searching ? searchedRooms[indexPath.row] : rooms[indexPath.row]
            let index = roomCodes.index(of: room.code)!
            roomCodes.remove(at: index)
            update()
            rooms.remove(at: index)
            if searching { searchedRooms.remove(at: indexPath.row) }
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = rooms[sourceIndexPath.row]
        rooms.remove(at: sourceIndexPath.row)
        rooms.insert(movedObject, at: destinationIndexPath.row)
        update()
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
        joinButton.backgroundColor = .green
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
        return searching ? searchedRooms.count : rooms.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RoomsCell
        
        cell.room = searching ? searchedRooms[indexPath.row] : rooms[indexPath.row]
        
        return cell
    }
}

