//
//  ChatVC.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 20/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import Firebase
import FirebaseFirestore
import InputBarAccessoryView
import MessageKit
import Photos
import UIKit

final class ChatViewController: MessagesViewController {
    private let user: User = Auth.auth().currentUser!
    var category: Category?

    private var messages: [Message] = []
    private var messageListener: ListenerRegistration?

    private let db = Firestore.firestore()
    private var reference: CollectionReference?

    private var isSendingPhoto = false {
        didSet {
            DispatchQueue.main.async {
                self.messageInputBar.leftStackViewItems.forEach { item in
                    guard let item = item as? InputBarButtonItem else { return }
                    item.isEnabled = !self.isSendingPhoto
                }
            }
        }
    }

    private let storage = Storage.storage().reference()

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

        messageListener = reference?.addSnapshotListener { querrySnapshot, error in
            guard let snapshot = querrySnapshot else {
                self.showMessage(for: "Error listening messages update:", with: error?.localizedDescription ?? "")
                return
            }

            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(for: change)
            }
        }

        let pictureButtonItem = InputBarButtonItem(type: .system)
        pictureButtonItem.tintColor = .primary
        pictureButtonItem.image = UIImage(systemName: "camera")

        pictureButtonItem.addTarget(self, action: #selector(imagePickerButtonPressed), for: .primaryActionTriggered)

        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)

        messageInputBar.setStackViewItems([pictureButtonItem], forStack: .left, animated: false)
    }

    // MARK: - Actions

    @objc func imagePickerButtonPressed() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }

        present(imagePicker, animated: true, completion: nil)
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
                if let url = message.media?.url {
                    downloadImage(at: url) { [weak self] image in
                        guard let self = self else { return }
                        guard let image = image else { return }

                        message.media = Image(url: url, image: image, placeholderImage: image, size: image.size)
                        self.insertNewMessage(message)
                    }
                } else {
                    insertNewMessage(message)
                }
            default:
                break
        }
    }

    private func showMessage(for title: String, with description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func uploadImage(_ image: UIImage, to category: Category, completition: @escaping (URL?) -> Void) {
        guard let categoryId = category.id else {
            completition(nil)
            return
        }

        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completition(nil)
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let storageRef = storage.child(categoryId).child(imageName)
        storageRef.putData(data, metadata: metadata) { meta, error in
            guard meta != nil else {
                self.showMessage(for: "Uplowad error...", with: error?.localizedDescription ?? "")
                completition(nil)
                return
            }

            storageRef.downloadURL { url, error in
                guard let url = url else {
                    self.showMessage(for: "Uplowad error...", with: error?.localizedDescription ?? "")
                    completition(nil)
                    return
                }

                completition(url)
            }
        }
    }

    private func sendPhoto(_ image: UIImage) {
        isSendingPhoto = true

        guard let category = category else { return }

        uploadImage(image, to: category) { [weak self] url in
            guard let `self` = self else {
                return
            }

            self.isSendingPhoto = false

            guard let url = url else { return }

            let message = Message(user: self.user, image: image)
            message.media?.url = url

            self.save(message)
            self.messagesCollectionView.scrollToBottom()
        }
    }

    private func downloadImage(at url: URL, completition: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)

        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                self.showMessage(for: "Download error...", with: error?.localizedDescription ?? "")
                completition(nil)
                return
            }

            completition(UIImage(data: imageData))
        }
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
        let paragraph = NSMutableParagraphStyle()

        paragraph.alignment = isFromCurrentSender(message: message) ? NSTextAlignment(.right) : NSTextAlignment(.left)

        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption2),
                .foregroundColor: UIColor(white: 0.3, alpha: 1),
                .paragraphStyle: paragraph
            ]
        )
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }

    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)

        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, _ in
                guard let image = result else { return }

                self.sendPhoto(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
