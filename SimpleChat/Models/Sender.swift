//
//  Sender.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 21/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var initials: String {
        var initials = ""
        let tab = displayName.split(separator: " ")

        if tab.count > 1 {
            initials.append(tab[0].first?.uppercased() ?? "")
            initials.append(tab[1].first?.uppercased() ?? "")
        } else {
            initials.append(tab[0].first?.uppercased() ?? "")
        }

        return initials
    }

    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
