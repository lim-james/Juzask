//
//  AnswersController.swift
//  Questions
//
//  Created by James on 7/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

class AnswersController: UITableViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    var question: Question!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = question.title
        adminLabel.text = question.admin
        answerLabel.text = question.answer
        
        adminLabel.font = UIFont.italicSystemFont(ofSize: adminLabel.font.pointSize)
        answerLabel.font = UIFont.boldSystemFont(ofSize: answerLabel.font.pointSize)
        answerLabel.textColor = .green
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

}
