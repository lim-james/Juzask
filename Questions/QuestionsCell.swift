//
//  QuestionCell.swift
//  Questions
//
//  Created by James on 6/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

class QuestionsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    
    var question: Question! {
        didSet {
            titleLabel.text = question.title
            adminLabel.text = question.admin
            
            titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
        }
    }

}
