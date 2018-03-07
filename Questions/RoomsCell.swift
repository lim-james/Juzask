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
    
    var room: Room! {
        didSet {
            titleLabel.text = room.title
            adminLabel.text = room.admin
            codeLabel.text = room.code
            
            titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
            codeLabel.textColor = .green
        }
    }

}
