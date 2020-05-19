//
//  Category.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import FirebaseFirestore

struct Category {
    let id: String?
    let name: String

    init(name: String) {
        id = nil
        self.name = name
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let name = data["name"] as? String else { return nil }

        id = document.documentID
        self.name = name
    }

}

extension Category: DatabaseRepresentation {
    var representation: [String : Any] {
        var rep = ["name" : name]

        if let id = id {
            rep["id"] = id
        }

        return rep
    }
}

extension Category: Comparable {
    static func < (lhs: Category, rhs: Category) -> Bool {
        return lhs.name < rhs.name
    }

    static func ==(lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}
