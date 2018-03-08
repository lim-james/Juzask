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
        
        let joinButton = UIButton()
        joinButton.setTitle("Join room", for: .normal)
        joinButton.frame = (navigationController?.toolbar.bounds)!
        joinButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.buttonFontSize)
        joinButton.backgroundColor = .green
        joinButton.addTarget(self, action: #selector(self.joinAction), for: .touchUpInside)
        
        let joinBarButton = UIBarButtonItem(customView: joinButton)
        
        navigationController?.toolbar.barTintColor = .green
        navigationController?.toolbar.isTranslucent = false
        toolbarItems = [joinBarButton]
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setToolbarHidden(false, animated: true)
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
        if tableView.isEditing {
            editButton.title = "Edit"
            tableView.setEditing(false, animated: true)
        }
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
            self.displayJoinAlert()
        }
    }
    
    func displayError(message: String, call: Int) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .cancel) { (action) in
            switch call {
            case 0: self.displayCreateAlert()
            case 1: self.displayJoinAlert()
            default: return
            }
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayCreateAlert() {
        let alertController = UIAlertController(title: "Enter room title", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Create", style: .default) { (_) in
            let field = alertController.textFields![0]
            self.checkCreate(title: field.text!)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { textField in
            textField.textAlignment = .center
            textField.returnKeyType = .done
            textField.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: false, completion: nil)
    }
    
    func checkCreate(title: String) {
        if title.exist() {
            
            let profile = GIDSignIn.sharedInstance().currentUser.profile
            let room = Room(title: title.chopped(), admin: (profile?.name)!, adminEmail: (profile?.email)!)
            roomCodes.append(room.code)
            update()
            room.create()
        } else {
            displayError(message: "Missing title", call: 0)
        }
    }
    
    func displayJoinAlert() {
        let alertController = UIAlertController(title: "Enter code", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Join", style: .default) { (_) in
            let field = alertController.textFields![0]
            self.checkJoin(code: field.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addTextField { textField in
            textField.textAlignment = .center
            textField.returnKeyType = .done
            textField.font = UIFont.systemFont(ofSize: UIFont.labelFontSize * 2)
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func checkJoin(code: String) {
        if roomCodes.contains(code) {
            displayError(message: "Group already added", call: 1)
            return
        }
        if code.exist() {
            ref.child("Rooms").observeSingleEvent(of: .value) { snapshot in
                if snapshot.hasChild(code) {
                    self.roomCodes.append(code)
                    self.update()
                    self.populate()
                } else {
                    self.displayError(message: "Group does not exist", call: 1)
                }
            }
        } else {
            displayError(message: "Missing code", call: 1)
        }
    }
    
    @IBAction func addRoomAction(_ sender: Any) {
        if GIDSignIn.sharedInstance().currentUser != nil {
            displayCreateAlert()
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
            navigationController?.setToolbarHidden(true, animated: true)
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
        let movedRoom = rooms[sourceIndexPath.row]
        rooms.remove(at: sourceIndexPath.row)
        rooms.insert(movedRoom, at: destinationIndexPath.row)
        
        let movedCode = roomCodes[sourceIndexPath.row]
        roomCodes.remove(at: sourceIndexPath.row)
        roomCodes.insert(movedCode, at: destinationIndexPath.row)
        
        update()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.alpha = 0
        UIView.animate(withDuration: 0.25) {
            cell.alpha = 1
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize * 2)
        label.textAlignment = .center
        label.textColor = .green
        label.text = "No rooms."
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return rooms.count == 0 ? view.frame.height : 0
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

