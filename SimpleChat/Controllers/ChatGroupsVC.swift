//
//  ChatGroupVC.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import UIKit

class ChatGroupsVC: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.hidesBackButton = true
    }

    @IBAction func logOutClicked(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func addCategoryClicked(_ sender: Any) {
        let alertWindow = UIAlertController(title: "Add new category", message: "Type category name", preferredStyle: .alert)

        alertWindow.addTextField { (textField) in
            textField.placeholder = "Category name..."
        }

        let addCategoryAction = UIAlertAction(title: "Add", style: .default) { _ in

        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertWindow.addAction(cancelAction)
        alertWindow.addAction(addCategoryAction)
        alertWindow.preferredAction = addCategoryAction
        present(alertWindow, animated: true, completion: nil)
    }
}
