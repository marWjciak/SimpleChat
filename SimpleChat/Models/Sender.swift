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

    init(senderId: String, displayName: String) {
        self.senderId = senderId
        self.displayName = displayName
    }
}
