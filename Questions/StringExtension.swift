
//
//  StringExtension.swift
//  Questions
//
//  Created by James on 6/3/18.
//  Copyright © 2018 james. All rights reserved.
//

import UIKit

extension String {
    func contains(_ substring: String) -> Bool {
        return self.range(of: substring) != nil
    }
}
