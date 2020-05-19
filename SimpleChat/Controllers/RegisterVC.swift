//
//  RegisterViewController.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import FirebaseAuth
import UIKit

class RegisterVC: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func registerClicked(_ sender: UIButton) {
        guard let emailAddress = emailTextField.text, let password = passwordTextField.text else {
            return
        }

        Auth.auth().createUser(withEmail: emailAddress, password: password) { _, error in
            if let error = error {
                self.showMessage(for: "User registration error...", with: error.localizedDescription)
            } else {
                self.performSegue(withIdentifier: K.registerToChatGroups, sender: self)
            }
        }
    }

    private func showMessage(for title: String, with description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
