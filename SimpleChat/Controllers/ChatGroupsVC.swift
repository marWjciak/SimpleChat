//
//  ChatGroupVC.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit

class ChatGroupsVC: UITableViewController {
    var categories = [Category]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: K.categoryCellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self

        navigationItem.hidesBackButton = true
        navigationItem.title = "Discussion groups"
    }

    @IBAction func logOutClicked(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func addCategoryClicked(_ sender: Any) {
        let alertWindow = UIAlertController(title: "Add new category", message: "Type category name", preferredStyle: .alert)
        var categoryName = UITextField()

        alertWindow.addTextField { (textField) in
            textField.placeholder = "Category name..."
            categoryName = textField
        }

        let addCategoryAction = UIAlertAction(title: "Add", style: .default) { _ in
            guard let categoryName = categoryName.text else { return }
            let category = Category(name: categoryName)
            self.addCategoryToList(category)

            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertWindow.addAction(cancelAction)
        alertWindow.addAction(addCategoryAction)
        alertWindow.preferredAction = addCategoryAction
        present(alertWindow, animated: true, completion: nil)
    }

    //MARK: - Helpers
    private func addCategoryToList(_ category: Category) {
        guard !categories.contains(category) else {
            return
        }

        categories.append(category)
        categories.sort()
    }
}


//MARK: - TableViewDelegate
extension ChatGroupsVC {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.categoryCellIdentifier, for: indexPath)

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
