//
//  ViewController.swift
//  SimpleChat
//
//  Created by Marcin Wójciak on 18/05/2020.
//  Copyright © 2020 Marcin Wójciak. All rights reserved.
//

import CLTypingLabel
import UIKit

class MainViewController: UIViewController {
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var logInButton: UIButton!
    @IBOutlet var logoLabel: CLTypingLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        initLogoAndButtons()
    }

    private func initLogoAndButtons() {
        logoLabel.font = UIFont(name: "Papyrus", size: 52.0)
        logoLabel.text = "SimpleChat"

        logoLabel.onTypingAnimationFinished = {
            self.registerButton.layer.cornerRadius = self.registerButton.frame.size.height * 0.50
            self.logInButton.layer.cornerRadius = self.registerButton.frame.size.height * 0.50

            self.registerButton.isHidden = false
            self.logInButton.isHidden = false
        }
    }
}
