//
//  ChatGroupVC.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit
import Firebase
import SwipeCellKit

class ChatGroupsVC: UITableViewController {
    private var currentChannelAlertController: UIAlertController?

    private let db = Firestore.firestore()
    private var categoryReference: CollectionReference {
        return db.collection("categories")
    }

    private var categories = [Category]()
    private var categoryListener: ListenerRegistration?

    private let currentUser: User? = Auth.auth().currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(SwipeTableViewCell.self, forCellReuseIdentifier: K.categoryCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self

        navigationItem.hidesBackButton = true
        navigationItem.title = currentUser?.email ?? "Categories"
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.systemBlue]

        categoryListener = categoryReference.addSnapshotListener({ (querrySnapshot, error) in
            guard let snapshot = querrySnapshot else {
                self.showMessage(for: "Error listening categories update:", with: error?.localizedDescription ?? "no errors")
                return
            }

            snapshot.documentChanges.forEach { (change) in
                self.handleDocumentChange(for: change)
            }
        })
    }

    @IBAction func logOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch (let error) {
            showMessage(for: "Sign Out error...", with: error.localizedDescription)
        }
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func addCategoryClicked(_ sender: Any) {
        let alertController = UIAlertController(title: "Add new category", message: "Type category name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.addTarget(self, action: #selector(self.textFieldDidChanged(_:)), for: .editingChanged)
            textField.placeholder = "Category name..."
            textField.clearButtonMode = .whileEditing
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addCategoryAction = UIAlertAction(title: "Add", style: .default) { _ in
            self.addCategory()
        }
        addCategoryAction.isEnabled = false

        alertController.addAction(cancelAction)
        alertController.addAction(addCategoryAction)
        alertController.preferredAction = addCategoryAction
        present(alertController, animated: true, completion: nil)

        self.currentChannelAlertController = alertController
    }

    @objc private func textFieldDidChanged(_ field: UITextField) {
        guard let alertController = self.currentChannelAlertController else { return }

        alertController.preferredAction?.isEnabled = field.hasText
    }

    //MARK: - Helpers
    private func addCategory() {
        guard let alertController = currentChannelAlertController else { return }
        guard let categoryName = alertController.textFields?.first?.text else { return }

        let category = Category(name: categoryName)
        categoryReference.addDocument(data: category.representation) { (error) in
            if let error = error {
                self.showMessage(for: "Error saving category...", with: error.localizedDescription)
            }
        }
    }

    private func removeCategory(_ category: Category) {
        guard let categoryId = category.id else {
            return
        }
        categoryReference.document(categoryId).delete() { (error) in
            if let error = error {
                self.showMessage(for: "Category remove failed...", with: error.localizedDescription)
            }
        }
    }

    private func addCategoryToList(_ category: Category) {
        guard !categories.contains(category) else {
            return
        }

        categories.append(category)
        categories.sort()

        guard let index = categories.firstIndex(of: category) else { return }
        tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    private func removeCategoryFromList(_ category: Category) {
        guard let index = categories.firstIndex(of: category) else { return }

        categories.remove(at: index)
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
    }

    private func showMessage(for title: String, with description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    private func handleDocumentChange(for change: DocumentChange) {
        guard let category = Category(document: change.document) else {
            return
        }

        switch change.type {
            case .added:
                self.addCategoryToList(category)
            case .modified:
                print("todo: modification")
            case .removed:
                self.removeCategoryFromList(category)
        }
    }
}


//MARK: - TableViewDelegate
extension ChatGroupsVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellIdentifier, for: indexPath) as! SwipeTableViewCell
        cell.delegate = self

        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = categories[indexPath.row].name

        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
}

extension ChatGroupsVC: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let category = self.categories[indexPath.row]
            self.removeCategory(category)
        }

        deleteAction.image = UIImage(systemName: "trash")

        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var swipeOptions = SwipeOptions()
        swipeOptions.expansionStyle = .destructive(automaticallyDelete: false)

        return swipeOptions
    }
}
