//
//  SessionsCell.swift
//  Questions
//
//  Created by James on 3/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

class RoomsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    
    var session: Room! {
        didSet {
            titleLabel.text = session.title
            adminLabel.text = session.admin
            codeLabel.text = "#" + session.code
            
            titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
        }
    }

}
