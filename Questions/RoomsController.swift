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
        ref.child("Rooms").observe(.value) { snapshot in
            self.rooms.removeAll()
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! [String: String]
                self.rooms.append(Room(from: dict))
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
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
    
    @IBAction func addRoomAction(_ sender: Any) {
        Room(title: "James", admin: "admin").create()
    }
}

