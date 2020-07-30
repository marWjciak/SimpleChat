//
//  Message.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 20/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Firebase
import FirebaseFirestore
import MessageKit

class Message: MessageType {
    let id: String?
    let content: String
    var sentDate: Date
    var sender: SenderType

    var kind: MessageKind {
        guard let mediaItem = media else { return .text(content) }
        return .photo(mediaItem)
    }

    var messageId: String {
        return id ?? UUID().uuidString
    }

    var media: Image?

    init(user: User, content: String) {
        let displayName = user.displayName ?? user.email
        sender = Sender(senderId: user.uid, displayName: displayName!)
        self.content = content
        media = nil
        sentDate = Date()
        id = nil
    }

    init(user: User, image: UIImage) {
        let displayName = user.displayName ?? user.email
        sender = Sender(senderId: user.uid, displayName: displayName!)
        content = ""
        media = Image(url: nil, image: image, placeholderImage: image, size: image.size)
        sentDate = Date()
        id = nil
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard let sentDate = data["created"] as? Timestamp else { return nil }
        guard let senderID = data["senderID"] as? String else { return nil }
        guard let senderName = data["senderName"] as? String else { return nil }

        id = document.documentID
        self.sentDate = sentDate.dateValue()
        sender = Sender(senderId: senderID, displayName: senderName)

        if let content = data["content"] as? String {
            media = nil
            self.content = content
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            media = Image(url: url, image: nil, placeholderImage: UIImage(), size: CGSize())
            content = ""
        } else {
            return nil
        }
    }

    func setImageItem(with url: URL, and image: UIImage) {
        media = Image(url: url, image: image, placeholderImage: image, size: image.size)
    }
}

extension Message: DatabaseRepresentation {
    var representation: [String: Any] {
        var rep: [String: Any] = [
            "created": sentDate,
            "senderID": sender.senderId,
            "senderName": sender.displayName
        ]

        if let url = media?.url {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }

        return rep
    }
}

extension Message: Comparable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }

    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
