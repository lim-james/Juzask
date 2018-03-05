//
//  ViewController.swift
//  Questions
//
//  Created by James on 3/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

class SessionsController: UITableViewController, UISearchResultsUpdating {

    var sessions: [Session] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        sessions.append(Session(title: "Math", admin: "Chen Jin Quan", code: "09Ab"))
        sessions.append(Session(title: "Math", admin: "Chen Jin Quan", code: "09Ab"))
        sessions.append(Session(title: "Math", admin: "Chen Jin Quan", code: "09Ab"))
        sessions.append(Session(title: "Math", admin: "Chen Jin Quan", code: "09Ab"))
        sessions.append(Session(title: "Math", admin: "Chen Jin Quan", code: "09Ab"))
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sessions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SessionsCell
        
        cell.session = sessions[indexPath.row]
        
        return cell
    }
    
}

