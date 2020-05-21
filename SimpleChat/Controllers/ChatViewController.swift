//
//  ChatVC.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 20/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit
import MessageKit
import Firebase

final class ChatViewController: MessagesViewController {
    let user: User = Auth.auth().currentUser!
    var category: Category?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = category?.name

        navigationItem.largeTitleDisplayMode = .never
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
    }
}
