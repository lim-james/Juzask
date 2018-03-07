//
//  QuestionCell.swift
//  Questions
//
//  Created by James on 6/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit
import GoogleSignIn

class QuestionsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var supportersLabel: UILabel!
    
    var question: Question! {
        didSet {
            titleLabel.text = question.title
            adminLabel.text = question.admin
            supportersLabel.text = "\(question.supporters.count) supporters"
            
            if question.supporters.contains(where: { (k, v) -> Bool in
                return v == GIDSignIn.sharedInstance().currentUser.profile.email
            }) {
                accessoryType = .checkmark
            } else {
                accessoryType = .none
            }
            
            titleLabel.font = UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize)
            
            if question.isAnswered {
                accessoryType = .disclosureIndicator
                backgroundColor = .green
                titleLabel.textColor = .white
                adminLabel.textColor = .white
                supportersLabel.textColor = .white
                
                supportersLabel.text = "Answered"
            } else {
                backgroundColor = .white
                titleLabel.textColor = .black
                adminLabel.textColor = .darkGray
                supportersLabel.textColor = .lightGray
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
}
