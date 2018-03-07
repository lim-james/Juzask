
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
    
    func chopped() -> String {
        return trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func exist() -> Bool {
        return !chopped().split(separator: " ").isEmpty
    }
}
