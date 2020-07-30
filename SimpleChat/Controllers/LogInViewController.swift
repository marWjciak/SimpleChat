//
//  LogInViewController.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import FirebaseAuth
import UIKit

class LogInViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        Auth.auth().addStateDidChangeListener { _, user in
            guard user != nil else { return }
            self.performSegue(withIdentifier: K.loginToChatGroups, sender: self)
        }
    }

    @IBAction func loginClicked(_ sender: UIButton) {
        guard let emailAddress = emailTextField.text, let password = passwordTextField.text else {
            return
        }

        Auth.auth().signIn(withEmail: emailAddress, password: password) { _, error in
            if let error = error {
                self.showMessage(for: "User login error...", with: error.localizedDescription)
            }
        }
    }

    private func showMessage(for title: String, with description: String) {
        let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))

        present(alertController, animated: true, completion: nil)
    }
}
