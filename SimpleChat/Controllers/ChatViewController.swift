//
//  ChatVC.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 20/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Firebase
import InputBarAccessoryView
import MessageKit
import UIKit

final class ChatViewController: MessagesViewController {
    private let user: User = Auth.auth().currentUser!
    var category: Category?

    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?

    private let db = Firestore.firestore()
    private var reference: CollectionReference?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let id = category?.id else {
            navigationController?.popViewController(animated: true)
            return
        }

        reference = db.collection(["categories", id, "thread"].joined(separator: "/"))

        title = category?.name

        navigationItem.largeTitleDisplayMode = .never
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        messageListener = reference?.addSnapshotListener({ (querrySnapshot, error) in
            guard let snapshot = querrySnapshot else {
                self.showMessage(for: "Error listening messages update:", with: error?.localizedDescription ?? "")
                return
            }

            snapshot.documentChanges.forEach { (change) in
                self.handleDocumentChange(for: change)
            }
        })
    }

    // MARK: - Helpers

    private func save(_ message: Message) {
        reference?.addDocument(data: message.representation) { error in
            if let error = error {
                self.showMessage(for: "Save failed...", with: error.localizedDescription)
            }

            self.messagesCollectionView.scrollToBottom()
        }
    }

    private func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else {
            return
        }

        messages.append(message)
        messages.sort()

        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToTheBottom = isLatestMessage

        messagesCollectionView.reloadData()

        if shouldScrollToTheBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

    private func handleDocumentChange(for change: DocumentChange) {
        guard let message = Message(document: change.document) else {
            return
        }

        switch change.type {
            case .added:
                insertNewMessage(message)
            default:
                break
        }
    }

    private func showMessage(for title: String, with description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}

extension ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return Sender(senderId: user.uid, displayName: user.email!)
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName

        return NSAttributedString(string: name,
                                  attributes: [
                                      .font: UIFont.preferredFont(forTextStyle: .caption1),
                                      .foregroundColor: UIColor(white: 0.3, alpha: 1)
                                  ])
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }

    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft

        return .bubbleTail(corner, .curved)
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let message = Message(user: user, content: text)

        inputBar.inputTextView.text = ""
        save(message)
    }
}
