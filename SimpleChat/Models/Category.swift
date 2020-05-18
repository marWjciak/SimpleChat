//
//  Category.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Foundation

struct Category {
    let id: String?
    let name: String

    init(name: String) {
        id = nil
        self.name = name
    }
}

extension Category: Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.name < rhs.name
    }

    static func ==(lhs: Category, rhs: Category) -> Bool {
        return lhs.name == rhs.name
    }
}
